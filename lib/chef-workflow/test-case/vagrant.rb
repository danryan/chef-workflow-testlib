require 'chef-workflow/support/vagrant'
require 'chef-workflow/support/vm/vagrant'
require 'chef-workflow/support/vm/knife'
require 'tempfile'
require 'chef-workflow/test-case/provisioned'
require 'chef-workflow/helpers/provision'
require 'chef-workflow/helpers/ssh'
require 'chef-workflow/support/vm/helpers/knife'

#
# Subclass of ProvisionHelper, centered around Vagrant. Pulls some
# configuration from KnifeSupport and then drives VM::VagrantProvisioner and
# VM::KnifeProvisioner.
#
class VagrantProvisionHelper < ProvisionHelper
  include KnifeProvisionHelper

  def provision(group_name, number_of_servers=1, dependencies=[])
    self.serial = true

    schedule_provision(
      group_name, 
      [
        VM::VagrantProvisioner.new(group_name, number_of_servers), 
        build_knife_provisioner
      ], 
      dependencies
    )
  end
end

#
# ProvisionedTestCase that uses VagrantProvisionHelper.
#
class MiniTest::Unit::VagrantTestCase < MiniTest::Unit::ProvisionedTestCase
  include SSHHelper
  extend SSHHelper

  self.provision_helper = VagrantProvisionHelper.new
end
