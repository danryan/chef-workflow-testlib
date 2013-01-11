require 'chef-workflow/support/vm/ec2'
require 'chef-workflow/support/vm/knife'
require 'tempfile'
require 'chef-workflow/test-case/provisioned'
require 'chef-workflow/helpers/provision'
require 'chef-workflow/helpers/ssh'

#
# Subclass of ProvisionHelper, centered around EC2. Pulls some
# configuration from KnifeSupport and then drives VM::EC2Provisioner and
# VM::KnifeProvisioner.
#
class EC2ProvisionHelper < ProvisionHelper
  def provision(group_name, number_of_servers=1, dependencies=[])
    kp               = VM::KnifeProvisioner.new
    kp.username      = KnifeSupport.singleton.ssh_user
    kp.password      = KnifeSupport.singleton.ssh_password
    kp.use_sudo      = KnifeSupport.singleton.use_sudo
    kp.ssh_key       = KnifeSupport.singleton.ssh_identity_file
    kp.environment   = KnifeSupport.singleton.test_environment
    kp.template_file = KnifeSupport.singleton.template_file

    schedule_provision(
      group_name, 
      [
        VM::EC2Provisioner.new(group_name, number_of_servers), 
        kp
      ], 
      dependencies
    )
  end
end

#
# ProvisionedTestCase that uses EC2ProvisionHelper
#
class MiniTest::Unit::EC2TestCase < MiniTest::Unit::ProvisionedTestCase
  include SSHHelper
  extend SSHHelper

  self.provision_helper = EC2ProvisionHelper.new
end
