require 'vagrant/dsl'
require 'chef-workflow/vagrant-support'
require 'chef-workflow/ip-support'

class << eval("self", TOPLEVEL_BINDING)
  def vagrant_build_role(role_name, number_of_machines=1)
    IPSupport.singleton.seed_vagrant_ips
    prison = vagrant_prison do
      configure do |config|
        config.vm.box_url = VagrantSupport.singleton.box_url
        config.vm.box = VagrantSupport.singleton.box
        number_of_machines.times do |count|
          ip = IPSupport.singleton.unused_ip
          IPSupport.singleton.assign_role_ip(role_name, ip)
          config.vm.define "#{role_name}_#{count}".to_sym do |this_config|
            this_config.vm.network :hostonly, ip
          end
        end
      end

      p @config.dir

      vagrant "up"
    end

    VagrantSupport.singleton.write_prison(role_name, prison)
    return prison, IPSupport.singleton.get_role_ips(role_name)
  end
end
