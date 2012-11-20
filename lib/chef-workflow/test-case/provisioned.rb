require 'chef-workflow/support/knife'
require 'minitest/unit'

class MiniTest::Unit::ProvisionedTestCase < MiniTest::Unit::TestCase
  @@dependencies = []

  def self.provision_helper=(arg)
    @@provision_helper = arg
  end

  def self.provision_helper
    @@provision_helper
  end

  def self.wait_for(*deps)
    @@provision_helper.wait_for(*deps)
  end

  def initialize(*args)
    Chef::Config.from_file(KnifeSupport.singleton.knife_config_path)
    
    @@dependencies.each do |group_name, number_of_servers, dependencies|
      self.class.provision_helper.provision(group_name, number_of_servers, dependencies)
    end

    self.class.provision_helper.run
    
    super
  end

  def wait_for(*dependencies)
    self.class.wait_for(*dependencies)
  end
  
  def provision(role, number_of_servers=1, addl_dependencies=[])
    self.class.provision_helper.provision(role, number_of_servers, @@dependencies.map(&:first) + addl_dependencies)
    self.class.provision_helper.run
  end

  def deprovision(role)
    self.class.provision_helper.deprovision(role)
  end
end
