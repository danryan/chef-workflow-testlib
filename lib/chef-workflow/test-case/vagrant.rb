require 'chef-workflow/support/vagrant'
require 'chef-workflow/support/vm/vagrant'
require 'chef-workflow/support/vm/knife'
require 'tempfile'
require 'chef-workflow/test-case/provisioned'
require 'chef-workflow/helpers/provision'

class VagrantProvisionHelper < ProvisionHelper
  def provision(group_name, number_of_servers=1, dependencies=[])
    self.serial = true

    kp              = VM::KnifeProvisioner.new
    kp.username     = KnifeSupport.singleton.ssh_user
    kp.password     = KnifeSupport.singleton.ssh_password
    kp.use_sudo     = KnifeSupport.singleton.use_sudo
    kp.ssh_key      = KnifeSupport.singleton.ssh_identity_file
    kp.environment  = KnifeSupport.singleton.test_environment

    schedule_provision(
      group_name, 
      [
        VM::VagrantProvisioner.new(group_name, number_of_servers), 
        kp
      ], 
      dependencies
    )
  end
end

class MiniTest::Unit::VagrantTestCase < MiniTest::Unit::ProvisionedTestCase
  self.provision_helper = VagrantProvisionHelper.new
end
