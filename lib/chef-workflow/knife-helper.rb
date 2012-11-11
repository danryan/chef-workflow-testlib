require 'knife/dsl'
require 'chef-workflow/knife-support'
require 'chef-workflow/ip-support'

# we patch Object here because we can't be as certain how these tools will be
# used.

class Object
  include Chef::Knife::DSL

  def knife_bootstrap_role(role_name, opts=Hash.new { |h,k| h[k] = [] })
    if opts[:run_list].nil? or opts[:run_list].empty?
      opts[:run_list] = [ "role[role_name]" ]
    end

    if opts[:run_list].nil? or opts[:bootstrap_args].empty?
      # use the vagrant settings by default
      opts[:bootstrap_args] = %w[-x vagrant -P vagrant --sudo]
    end

    ips = IPSupport.singleton.get_role_ips(role_name)
    role_name_counter = 1 
    node_names = []
    ips.each do |ip|
      node_name = [role_name, role_name_counter].join("-")
      stdout, stderr, status = knife_capture :bootstrap, %W[-N #{node_name} -r '#{run_list.join(",")}'] + opts[:bootstrap_args] + [ip]
      if status == 0
        node_names << node_names
      else
        $stderr.puts "Knife Bootstrap failed for #{node_name}/#{ip}:"
        $stderr.puts "------ STDOUT -------" 
        $stderr.puts stdout
        $stderr.puts "------ STDERR -------"
        $stderr.puts stderr
        $stderr.puts "Exit code: #{status}"
        fail
      end
    end

    return node_names
  end
end
