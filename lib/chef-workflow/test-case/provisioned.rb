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
  module ProvisionHelper
    #
    # wait for a provision. takes a list of server group names. delegates to the
    # provision helper.
    #
    def wait_for(*deps)
      provision_helper.wait_for(*deps)
    end

    #
    # Provision a server group. Takes a name, number of servers, and a list of
    # dependencies (server group names). Delegates to the provision helper.
    #
    def provision(role, number_of_servers=1, addl_dependencies=[])
      provision_helper.provision(role, number_of_servers, addl_dependencies)
      provision_helper.run
    end

    #
    # De-Provision a server group. Takes a name. Delegates to the provision
    # helper.
    #
    def deprovision(role)
      provision_helper.deprovision(role)
    end

    #
    # Obtains the IP addresses for a given role as an array.
    #
    def get_role_ips(role)
      IPSupport.singleton.get_role_ips(role)
    end

    #
    # Easy way to reference KnifeSupport for getting configuration data.
    #
    def knife_config
      KnifeSupport.singleton
    end
  end

  include ProvisionHelper
  extend ProvisionHelper

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
end
