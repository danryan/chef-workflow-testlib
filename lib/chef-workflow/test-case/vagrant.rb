require 'chef-workflow/vagrant-helper'
require 'minitest/unit'

class MiniTest::Unit::VagrantTestCase < MiniTest::Unit::TestCase
  include VagrantHelper

  attr_reader :bootstrap_details
  attr_writer :role_configuration
  attr_writer :role_order

  def role_configuration(arg=nil)
    if arg
      @role_configuration = arg
    end

    @role_configuration
  end

  def role_order(arg=nil)
    if arg
      @role_order = arg
    end

    @role_order
  end

  def role_order_append(arg)
    @role_order ||= []
    @role_order.push(arg)
  end

  def role_configuration_merge(arg)
    @role_configuration ||= { }
    @role_configuration.merge!(arg)
  end

  def setup
    super

    at_exit { teardown }

    unless respond_to?(:configure_prison)
      raise "configure_prison must be defined in this test suite."
    end

    configure_prison

    unless role_configuration
      raise "please define `bootstrap_role` and `node_count` in your configure_prison routine"
    end

    self.role_order ||= []

    @bootstrap_details = { }

    if role_order
      role_order.each do |key|
        # extract the number of machines and potential flags

        node_count  = 0
        flags       = []

        if role_configuration[key].kind_of?(Array)
          node_count, *flags = role_configuration[key]
        else
          node_count = role_configuration[key]
        end

        prison, ips, node_names = vagrant_bootstrap(key.to_s, node_count)

        @bootstrap_details[key] = {
          :prison     => prison,
          :ips        => ips,
          :node_names => node_names
        }
      end

      role_order.each do |key|
        next unless role_configuration[key].kind_of?(Array)
        node_count, *flags = role_configuration[key]

        if flags.include?(:double_converge)
          # FIXME 'sudo chef-client' probably isn't going to work for everyone, macro this up 
          status = knife :ssh, [ips.join(" ")] + %w[-m -x vagrant -P vagrant] + [ 'sudo chef-client' ]
          fail unless status == 0
        end
      end
    else
      # FIXME finish
    end
  end
  
  def teardown
    super

    role_order.reverse.each do |key|
      if @bootstrap_details[key]
        vagrant_cleanup(@bootstrap_details[key][:prison], @bootstrap_details[key][:node_names])
      end
    end
  end
end
