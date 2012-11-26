require 'chef-workflow/support/ip'
require 'chef-workflow/support/knife'
require 'chef-workflow/support/debug'
require 'net/ssh'

#
# Helper for performing SSH on groups of servers. Intended to be mixed into test case classes.
#
module SSHHelper
  include KnifePluginSupport
  include DebugSupport

  #
  # run a command against a group of servers. These commands are run in
  # parallel, but the command itself does not complete until all the threads
  # have finished running.
  #
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

  #
  # Run a command against a single IP. Makes heavy use of KnifeSupport to
  # determine how to drive the command.
  #
  def ssh_command(ip, command)
    command = "#{KnifeSupport.singleton.use_sudo ? 'sudo ': ''}#{command}"

    options = { }

    options[:password] = KnifeSupport.singleton.ssh_password          if KnifeSupport.singleton.ssh_password
    options[:keys]     = [KnifeSupport.singleton.ssh_identity_file]   if KnifeSupport.singleton.ssh_identity_file

    Net::SSH.start(ip, KnifeSupport.singleton.ssh_user, options) do |ssh|
      ssh.open_channel do |ch|
        ch.on_open_failed do |ch, code, desc|
          raise "Connection Error to #{ip}: #{desc}"
        end

        ch.exec(command) do |ch, success|
          return 1 unless success

          if_debug(2) do
            ch.on_data do |ch, data|
              $stderr.puts data
            end
          end

          ch.on_request("exit-status") do |ch, data|
            return data.read_long
          end
        end
      end

      ssh.loop
    end
  end
end
