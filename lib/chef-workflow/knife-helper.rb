require 'knife/dsl'
require 'chef-workflow/knife-support'
require 'chef-workflow/ip-support'
require 'thread'
require 'stringio'

module KnifeHelper
  include Chef::Knife::DSL

  # FIXME probably should just add this to knife/dsl
  def knife_mute
    null = Gem.win_platform? ? File.open('NUL:', 'r') : File.open('/dev/null', 'r')
    # HACK: knife_capture isn't thread safe because this hack isn't thread
    # safe. Work to get the UI fixes in Chef::Knife proper.
    warn = $VERBOSE 
    $VERBOSE = nil
    stderr, stdout, stdin = STDERR, STDOUT, STDIN

    Object.const_set("STDERR", StringIO.new('', 'r+'))
    Object.const_set("STDOUT", StringIO.new('', 'r+'))
    Object.const_set("STDIN", null)
    $VERBOSE = warn

    begin
      return yield
    rescue RuntimeError => e
      stdout_string = STDOUT.string
      stderr_string = STDERR.string
      knife_loud(stderr, stdout, stdin, null)
      $stderr.puts "#{e.class.name}: #{e.message}"
      $stderr.puts "Output follows:"
      $stderr.puts "----- STDOUT -----"
      $stderr.puts stdout_string
      $stderr.puts "----- STDERR -----"
      $stderr.puts stderr_string
    end
  ensure
    knife_loud(stderr, stdout, stdin, null)
  end

  def knife_loud(stderr, stdout, stdin, null)
    warn = $VERBOSE 
    $VERBOSE = nil
    Object.const_set("STDERR", stderr)
    Object.const_set("STDOUT", stdout)
    Object.const_set("STDIN", stdin)
    $VERBOSE = warn
    null.close
  end

  def knife_bootstrap_role(role_name, opts=Hash.new { |h,k| h[k] = [] })
    if opts[:run_list].nil? or opts[:run_list].empty?
      opts[:run_list] = [ "role[#{role_name}]" ]
    end

    if opts[:bootstrap_args].nil? or opts[:bootstrap_args].empty?
      # use the vagrant settings by default
      opts[:bootstrap_args] = %W[-x vagrant -P vagrant --sudo -E #{KnifeSupport.singleton.test_environment}]
    end

    ips = IPSupport.singleton.get_role_ips(role_name)
    $stderr.puts "bootstrapping #{ips.count} machines with #{role_name} and run_list #{opts[:run_list].join(",")}"

    node_names = []

    knife_mute do
      mut = Mutex.new
      threads = []

      ips.each_with_index do |ip, role_name_counter|
        threads << Thread.new do 
          node_name = [role_name, role_name_counter].join("-")

          warn = $VERBOSE
          $VERBOSE = nil
          status = knife :bootstrap, %W[-N #{node_name} -r '#{opts[:run_list].join(",")}'] + opts[:bootstrap_args] + [ip]
          $VERBOSE = warn 
          raise "Trouble bootstrapping #{node_name}/#{ip}" unless status == 0

          mut.synchronize do
            node_names << node_name
          end
        end
      end

      threads.map(&:join)
    end

    node_names
  end
  
  def knife_destroy(node_names)
    knife_mute do
      threads = []
      node_names.each do |node|
        threads << Thread.new do
          status = knife %W[node delete #{node} -y]
          raise "Could not delete node #{node}" unless status == 0
          status = knife %W[client delete #{node} -y]
          raise "Could not delete client #{node}" unless status == 0
        end
      end

      threads.map(&:join)
    end
  end
end
