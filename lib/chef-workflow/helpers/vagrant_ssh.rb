require 'chef-workflow/support/ip'
require 'chef-workflow/support/knife'
require 'chef-workflow/support/debug'
require 'chef-workflow/support/vm'
require 'vagrant'
require 'minitest/unit'

module VagrantSSHHelper
  include KnifePluginSupport
  include DebugSupport

  def vagrant_ssh_role_command(role, command)
    t = []

    vagrant = VM.load_from_file.groups[role].find { |v| v.is_a?(VM::VagrantProvisioner) }

    vagrant.prison.env.vms.each do |name, vm|
      t.push(
        Thread.new do
          vagrant_ssh_command(vm, command)
        end
      )
    end
    t.each(&:join)
  end

  def vagrant_ssh_command(vm, command, show_output=false)
    vm.channel.execute(command) do |stream, data|
      next if data =~ /stdin: is not a tty/
      if [:stderr, :stdout].include?(stream) && show_output
        color = stream == :stdout ? :green : :red
        vm.ui.info(data, :color => color, :prefix => true)
      end
    end
  end
end
