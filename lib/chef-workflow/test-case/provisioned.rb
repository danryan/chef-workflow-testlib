require 'chef-workflow/support/knife'
require 'minitest/unit'

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
  # wait_for as a class method -- not entirely sure why this is here.
  #
  def self.wait_for(*deps)
    @@provision_helper.wait_for(*deps)
  end

  #
  # Constructor. Be sure in your subclasses to call this with `super`.
  # Provisions machines configured as dependencies and starts the scheduler.
  #
  def initialize(*args)
    Chef::Config.from_file(KnifeSupport.singleton.knife_config_path)
    
    @@dependencies.each do |group_name, number_of_servers, dependencies|
      self.class.provision_helper.provision(group_name, number_of_servers, dependencies)
    end

    self.class.provision_helper.run
    
    super
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
  def provision(role, number_of_servers=1, addl_dependencies=[])
    self.class.provision_helper.provision(role, number_of_servers, @@dependencies.map(&:first) + addl_dependencies)
    self.class.provision_helper.run
  end

  #
  # De-Provision a server group. Takes a name. Delegates to the provision
  # helper.
  #
  def deprovision(role)
    self.class.provision_helper.deprovision(role)
  end
end
