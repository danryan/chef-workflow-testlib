Chef Workflow - Test Libraries and Tooling
------------------------------------------

This gem provides a set of libraries to drive
[minitest](https://github.com/seattlerb/minitest) integration for a number of things:

1. spawning whole networks of machines
2. testing their converge successes
3. testing interoperability between machines
4. testing advanced functionality in chef, like search.

This library is not intended for testing individual cookbooks, or even a
`run_list` on a single machine.
[chef-workflow-tasklib](https://github.com/chef-workflow/chef-workflow-tasklib)
contains functionality to do this with minitest-chef-handler if you so desire.

Most of the Meat is on the Wiki
-------------------------------

This project is a part of
[chef-workflow](https://github.com/chef-workflow/chef-workflow).

Our [wiki](https://github.com/chef-workflow/chef-workflow/wiki) contains
a fair amount of information, including how to try chef-workflow without
actually doing anything more than cloning a repository and running a few
commands.

Contributing
------------

* fork the project
* make a branch
* add your stuff
* push your branch to your repo
* send a pull request

**Note:** modifications to gem metadata, author lists, and other credits
without rationale will be rejected immediately.

Credits
-------

Author: [Erik Hollensbe](https://github.com/erikh)

These companies have assisted by donating time, financial resources, and
employment to those working on chef-workflow. Supporting OSS is really really
cool and we should reciprocate.

* [HotelTonight](http://www.hoteltonight.com) 
