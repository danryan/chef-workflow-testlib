require 'knife/dsl'
require 'chef-workflow/knife-support'
require 'chef-workflow/ip-support'
require 'chef-workflow/debug-support'
require 'thread'
require 'stringio'

module KnifeHelper
  include DebugSupport
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
    null.close rescue nil
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

    if_debug do
      $stderr.puts "bootstrapping #{ips.count} machines with #{role_name} and run_list #{opts[:run_list].join(",")}"
    end

    node_names = []

    run_bootstrap = lambda do
      Chef::Config.from_file(ENV["CHEF_CONFIG"]) # FIXME this is a stupid thing to do here
      mut = Mutex.new
      threads = []

      ips.each_with_index do |ip, role_name_counter|
        threads << Thread.new do 
          node_name = [role_name, role_name_counter].join("-")

          warn = $VERBOSE
          $VERBOSE = nil
          # knife bootstrap is the honey badger when it comes to exit status.
          # We can't rely on it, so we examine the run_list of the node instead
          # to ensure it converged.
          knife :bootstrap, %W[-N #{node_name} -r '#{opts[:run_list].join(",")}'] + opts[:bootstrap_args] + [ip]
          run_list_size = Chef::Node.load(node_name).run_list.to_a.size

          # cleanup.
          # FIXME refactor this crap
          unless run_list_size > 0
            #knife %W[node delete #{node_name} -y]
            #knife %W[client delete #{node_name} -y]
            $VERBOSE = warn 
            raise "Trouble bootstrapping #{node_name}/#{ip}"
          end

          $VERBOSE = warn 

          mut.synchronize do
            node_names << node_name
          end
        end
      end

      threads.map(&:join)
    end

    if_debug(1, lambda { knife_mute(&run_bootstrap) }, &run_bootstrap)

    # chef's solr/couch EC really screws us here. even though the nodes are
    # bootstrapped, there's no guarantee they'll be available for querying at
    # this point. So, we wait until we can see all of them which prevents a
    # whole class of false negatives in tests.

    if_debug do
      $stderr.puts "Waiting for chef to index our nodes"
    end

    run_list_item = opts[:run_list].first.dup

    # this dirty hack turns 'role[foo]' into 'roles:foo', but also works on
    # recipe[] too.
    run_list_item.gsub!(/\[/, 's:"')
    run_list_item.gsub!(/\]/, '"')

    unchecked_node_names = node_names.dup

    until unchecked_node_names.empty?
      name = unchecked_node_names.shift
      if_debug(2) do
        $stderr.puts "Checking search validity for node #{name}"
      end
      stdout, stderr = knife_capture :search_node, %W[#{run_list_item} AND name:#{name}]
      unless stdout =~ /1 items found/
        unchecked_node_names << name
      end
      # unfortunately if this isn't here you might as well issue kill -9 to the
      # rake process
      sleep 0.3
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
