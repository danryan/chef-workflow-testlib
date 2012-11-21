require 'chef-workflow/support/ip'
require 'chef-workflow/support/vagrant'
require 'chef-workflow/support/vm/vagrant'
require 'chef-workflow/support/vm/knife'
require 'vagrant/prison'
require 'tempfile'
require 'chef-workflow/test-case/provisioned'
require 'chef-workflow/helpers/provision'

class VagrantProvisionHelper < ProvisionHelper
  def provision(group_name, number_of_servers=1, dependencies=[])
    self.serial = true

    ips = []
    prison = Vagrant::Prison.new(Dir.mktmpdir, false)
    prison.configure do |config|
      config.vm.box_url = VagrantSupport.singleton.box_url
      config.vm.box = VagrantSupport.singleton.box
      number_of_servers.times do |x|
        ip = IPSupport.singleton.unused_ip
        IPSupport.singleton.assign_role_ip(group_name, ip)
        config.vm.define "#{group_name}-#{x}" do |this_config|
          this_config.vm.network :hostonly, ip
        end
        ips << ip
      end
    end

    kp = VM::KnifeProvisioner.new
    kp.username = 'vagrant'
    kp.password = 'vagrant'
    kp.use_sudo = true
    kp.environment = 'vagrant'

    schedule_provision(group_name, [VM::VagrantProvisioner.new(prison, ips), kp], dependencies)
  end

  # FIXME this is not the place to do this, move it for EC2 support
  def deprovision(group_name)
    super
    IPSupport.singleton.delete_role(group_name)
  end
end

class MiniTest::Unit::VagrantTestCase < MiniTest::Unit::ProvisionedTestCase
  self.provision_helper = VagrantProvisionHelper.new
end
