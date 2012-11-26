# Chef Workflow - Test Libraries and Tooling

This gem provides a set of libraries to drive
[minitest](https://github.com/seattlerb/minitest) integration for spawning
whole networks of machines, testing their converge successes, interop between
machines and chef-server functionality.

## Installation

Add this line to your application's Gemfile:

    gem 'chef-workflow-testlib'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chef-workflow-testlib

## Quick Start

The easiest way to get started is to integrate
[chef-workflow-tasklib](https://github.com/hoteltonight/chef-workflow-tasklib)
into your environment. This has a number of benefits, such as working within
the same system to control machine provisioning, building a chef server,
uploading your repository to a chef server, several options for driving tests,
and so on. Once you've set that up, use the instructions over there to build a
test chef server.

So, after you've done that go ahead and create a `test` directory at the root
of your repository. Inside that, create a `test_mytest.rb` that provisions a
few machines and performs a search on them. This actually doesn't have much
real-world application, but it'll get you familiar with the workflow.

You will need some working roles to perform this test. We'll name these roles
`my_role` and `my_other_role` in the example, but you'll need to replace them
with roles you actually use.

This test will use `vagrant` to provision your machines, bootstrap them with
knife, then run your tests. After it's done, it will tear those machines down.
If the nodes fail to come up for any reason, your test should yield an error
and deprovision the machines.

```ruby
require 'chef-workflow/helper'
class MyTest < MiniTest::Unit::VagrantTestCase
  def setup
    provision('my_role')
    provision('my_other_role')
    wait_for('my_role')
    wait_for('my_other_role')
  end

  def teardown
    deprovision('my_role')
    deprovision('my_other_role')
  end

  def test_searching_one
    assert_search_count(:node, 'roles:my_role', 1)
  end

  def test_searching_two
    assert_search_count(:node, 'roles:my_other_role', 1)
  end
end
```

Then run your test suite with `bundle exec rake test:build`, which will perform
an upload of your repository to the test chef server, and run your tests.

We're quite aware this takes a while to run, and does very little. There are a
couple of ways to deal with this, but involve understanding the system a little
more; something we're about to cover.

## Dealing with Slow

Ok, so we got our test suite off the ground, and boy do those tests take a
while to run. I have two bits of good news for you:

EC2 support is coming, and a parallel provisioner has already been written to
reduce provisioning time. Vagrant (actually VirtualBox) cannot be parallelized
for a number of reasons. I expect EC2 support to be ready before the first
release, so if you're seeing this, chances are I gave you the URL ahead of
time or you found it on your own. So be nice. Additional provisioners should be
moderately easy to write, but there is no guide on how to do so just yet.

The second is that in most scenarios, you have a few servers that you don't
really care about for this test, but need to be available for the machine to
function or converge properly, like a DNS or syslog server. All provisioning is
tracked and the state information is actually written to disk in your
`.chef-workflow` directory.  What that means is that if you don't need to
rebuild your machines, you don't actually have to until you're ready to.

### State Management with MiniTest Subclasses

Let's start off easy. Take our example above, and remove the deprovisioning
lines in the `teardown` call:

```ruby
require 'chef-workflow/helper'
class MyTest < MiniTest::Unit::VagrantTestCase
  def setup
    provision('my_role')
    provision('my_other_role')
    wait_for('my_role')
    wait_for('my_other_role')
  end

  def teardown
    # omg, where did they go?
  end

  def test_searching_one
    assert_search_count(:node, 'roles:my_role', 1)
  end

  def test_searching_two
    assert_search_count(:node, 'roles:my_other_role', 1)
  end
end
```

And run your tests again. Go ahead, run them twice. The second time should be
pretty quick, in the order of a second or so. This is because your machines
weren't provisioned the second time; the system determined they were already
built and didn't have to provision them again.

So how do we clean them up? `bundle exec rake chef:clean:machines`, or add our
deprovisioning lines back in and run the suite again. The state for a provision
lasts until the machine is deprovisioned, whether or not that's the same test
run. The rake task just reaps everything except for your chef server.

Now that we've seen the obvious performance increase, what is this good for?

### Pre-baking essential infra with MiniTest subclasses

MiniTest (and all SUnit alikes) leverage subclassing pretty heavily when done
right to manage a common set of test dependencies. For example, we have a
subclass called 'WithInfra' in our test suite that looks like this:

```ruby
class MiniTest::Unit::VagrantTestCase::WithInfra < MiniTest::Unit::VagrantTestCase
  include SSHHelper

  @@dependencies += [
    ['bind_master', 1, []],
    ['syslog_server', 1, []]
  ]

  def initialize(*args)
    super
    wait_for('bind_master', 'syslog_server')
    ssh_role_command('bind_master', 'chef-client')
    ssh_role_command('syslog_server', 'chef-client')
  end
end
```

`SSHHelper` is a small mixin that provides `ssh_role_command` and other bits of
ssh-related functionality. In this case, our syslog depends on working DNS and
our BIND depends on working syslog; while they have cookbooks that are smart
enough to walk past those dependencies in the first chef run, once they're both
up converging them again will resolve each other and configure them
appropriately.

**The next bit I hope to make a little easier to use in the near future, but
here's the gory details**:

`@@dependencies` is a small structure which is intended to be appended to, and
describes in each array a call to `provision`. Consequently, the role, number
of servers to provision, and the servers it depends on (more on this later) are
listed here. This is done in the `initialize` routine of the parent class,
which we call immediately, then we wait for them to provision, then do a second
chef-client run with our SSH tooling. 

The good news is that we don't have to (but can) tear these servers down during
a run or even between runs if they're not causing problems, and you can always
check from a fresh provision by running the `chef:clean:machines` task before
`test`, or simply `test:rebuild`, which does a full deprovision, repository
upload, and test run. This saves you time (and money, in the EC2 case) and
still gives you a way to do a "full" run without a lot of extra work.

An actual test suite that uses this looks like this:

```ruby
class TestBIND < MiniTest::Unit::VagrantTestCase::WithInfra
  def setup
    provision('bind_slave', 1, %w[bind_master syslog_server])
    wait_for('bind_slave')
  end

  def test_something
    # maybe a test that nsupdates the master and ensures it made it to slave
    # could go here
  end

  def teardown
    deprovision('bind_slave') 
  end
end
```

This test when run will create, test, and destroy the bind slave, but leave the
master and the syslog server alone -- something that we will undoubtedly need
for the next test case.

### Dependency-based Provisioning

All provisions have a dependency list. Until they are satisfied, the stated
provision will not happen. This is mostly noticable in threaded provisioning
mode where multiple provisions can occur at once.

To wait for a specific machine to provision before continuing the test process,
use the `wait_for` method.

We can see this in our example above:

```ruby
  def setup
    provision('bind_slave', 1, %w[bind_master syslog_server])
    wait_for('bind_slave')
  end
```

In this instance, a `bind_slave` provision is scheduled, which depends on the
`bind_master` and `syslog_server` provisions. The `wait_for` statement is used
to control the test flow, so that it does not continue before `bind_slave`
provisions, which is what we want to actually test in this test case. Properly
used, this can enhance provisioning times by letting the scheduler provision
things as soon as they are capable of being provisioned, where you just care
about the servers you wish to test at any given point, instead of having to
manage this problem yourself.

You can't declare provisions that are dependent on provisions that don't exist
-- this will raise an exception. So, don't worry about fat-fingering it. :)

Here's a more advanced example that abuses the performance gains of the
scheduler. In this instance, we instend to test our monitoring system, which
will assert the "alive" status of many servers. We provision numerous ones in
the setup, and only wait for what we care about in each unit test.

```ruby
class TestNagios < MiniTest::Unit::VagrantTestCase
  def setup
    provision('syslog_server')
    provision('bind_master', 1, %w[syslog_server])
    # we just care about bind for all these
    provision('bind_slave', 1, %w[bind_master])
    provision('web_server', 1, %w[bind_master])
    provision('db_server', 1, %w[bind_master])
    provision('nagios_server', 1, %w[bind_master])
    # we need the nagios server available for all tests, so wait for that
    wait_for('nagios_server')
  end

  def test_dns_monitoring
    wait_for('bind_master', 'bind_slave')
    # ensure monitoring works
  end

  def test_web_monitoring
    wait_for('web_server')
    # ensure monitoring works
  end

  def test_db_monitoring
    wait_for('db_server')
    # ensure monitoring works
  end

  def teardown
    %w[
        bind_master 
        bind_slave 
        syslog_server 
        web_server 
        db_server 
        nagios_server
    ].each { |x| deprovision(x) }
  end
end
```

The flow of this test is as such:

As soon as `bind_master` completes, `bind_slave`, `web_server`, `db_server`,
and `nagios_server` will begin provisioning. `setup` will wait until
`nagios_server` completes, and normal testing will begin. Each test waits for
its testable unit to finish provisioning before running the actual tests
against those units. With rare exception, after a test or two, the `wait_for`
commands will succeed immediately, largely because they have been provsioning
in the background while the other tests have been running.

If you're curious how all this works under the hood, see the
[chef-workflow](https://github.com/hoteltonight/chef-workflow) documentation on
the subject.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
6. Adjustment of the license terms or the author credits will result in a
   rejected pull request. It ain't cool, yo.

## Authors

This work is sponsored by [HotelTonight](http://hoteltonight.com), and you
should check them out. We use this system for testing our infrastructure. The
programming was done primarily by [Erik Hollensbe](https://github.com/erikh).
