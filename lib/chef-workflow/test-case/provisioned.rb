require 'chef-workflow/support/knife'
require 'chef-workflow/runner/provisioned'



#
# Basic provisioned test case. Generally not intended for direct use but
# provides the scaffolding for subclasses.
#
# Set the class attribute `provision_helper` to configure your provision
# helper, which will be used for many methods this class provides.
#
class MiniTest::Unit::ProvisionedTestCase < MiniTest::Unit::TestCase
  @@dependencies = []

  #
  # Sets the provision helper.
  #
  def self.provision_helper=(arg)
    @@provision_helper = arg
  end

  #
  # Retrieves the provision helper.
  #
  def self.provision_helper
    @@provision_helper
  end

  #
  # wait_for as a class method
  #
  def self.wait_for(*deps)
    provision_helper.wait_for(*deps)
  end

  #
  # provision as a class method
  #
  def self.provision(role, number_of_servers=1, addl_dependencies=[])
    provision_helper.provision(role, number_of_servers, @@dependencies.map(&:first) + addl_dependencies)
    provision_helper.run
  end

  #
  # deprovision as a class method
  #
  def self.deprovision(role)
    provision_helper.deprovision(role)
  end

  #
  # Hook before the suite starts. Be sure in your subclasses to call this with
  # `super`. Provisions machines configured as dependencies and starts the
  # scheduler.
  #
  def self.before_suite
    super

    Chef::Config.from_file(KnifeSupport.singleton.knife_config_path)
    
    @@dependencies.each do |group_name, number_of_servers, dependencies|
      provision_helper.provision(group_name, number_of_servers, dependencies)
    end

    provision_helper.run
  end

  #
  # wait for a provision. takes a list of server group names. delegates to the
  # provision helper.
  #
  def wait_for(*dependencies)
    self.class.wait_for(*dependencies)
  end
 
  #
  # Provision a server group. Takes a name, number of servers, and a list of
  # dependencies (server group names). Delegates to the provision helper.
  #
  def provision(*args)
    self.class.provision(*args)
  end

  #
  # De-Provision a server group. Takes a name. Delegates to the provision
  # helper.
  #
  def deprovision(*args)
    self.class.deprovision(*args)
  end
end
