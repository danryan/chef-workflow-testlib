require 'chef-workflow/support/ip'
require 'chef-workflow/support/knife'
require 'chef-workflow/support/debug'
require 'chef/application/knife'
require 'chef/knife/ssh'

module SSHHelper
  include KnifePluginSupport
  include DebugSupport

  def ssh_role_command(role, command)
    t = []
    IPSupport.singleton.get_role_ips(role).each do |ip|
      t.push(
        Thread.new do
          ssh_command(ip, command)
        end
      )
    end
    t.each(&:join)
  end

  def ssh_command(ip, command)
    args = %W['#{ip}' '#{KnifeSupport.singleton.use_sudo ? 'sudo ': ''}#{command}' -m]

    args += %W[-x '#{KnifeSupport.singleton.ssh_user}']       if KnifeSupport.singleton.ssh_user
    args += %W[-P '#{KnifeSupport.singleton.ssh_password}']   if KnifeSupport.singleton.ssh_password
    args += %W[-i '#{KnifeSupport.singleton.ssh_identity_file}']  if KnifeSupport.singleton.ssh_identity_file

    $stderr.puts args.inspect

    cli = init_knife_plugin(Chef::Knife::Ssh, args)
    status = cli.run

    if status == 0
      if_debug do
        puts cli.ui.stdout.string
        puts cli.ui.stderr.string
      end

      return true
    end

    puts cli.ui.stdout.string
    puts cli.ui.stderr.string
    raise "SSH command failed for ip #{ip}, command #{command}"
  end
end
