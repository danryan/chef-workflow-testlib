require 'chef-workflow/support/vm/ec2'
require 'chef-workflow/support/vm/knife'
require 'tempfile'
require 'chef-workflow/test-case/provisioned'
require 'chef-workflow/helpers/provision'
require 'chef-workflow/helpers/ssh'
require 'chef-workflow/support/vm/helpers/knife'

#
# Subclass of ProvisionHelper, centered around EC2. Pulls some
# configuration from KnifeSupport and then drives VM::EC2Provisioner and
# VM::KnifeProvisioner.
#
class EC2ProvisionHelper < ProvisionHelper
  include KnifeProvisionHelper

  def provision(group_name, number_of_servers=1, dependencies=[])
    schedule_provision(
      group_name, 
      [
        VM::EC2Provisioner.new(group_name, number_of_servers), 
        build_knife_provisioner
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
