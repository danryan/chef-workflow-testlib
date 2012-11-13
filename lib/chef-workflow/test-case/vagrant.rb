require 'chef-workflow/vagrant-helper'
require 'minitest/unit'

class MiniTest::Unit::VagrantTestCase < MiniTest::Unit::TestCase
  include VagrantHelper

  %w[bootstrap_role node_count].each do |meth|
    class_eval <<-EOF
      def #{meth}=(arg)
        @#{meth} = arg
      end

      def #{meth}(arg=nil)
        if arg
          @#{meth} = arg
        end
        @#{meth}
      end
    EOF
  end

  def setup
    super

    unless respond_to?(:configure_prison)
      raise "configure_prison must be defined in this test suite."
    end

    configure_prison

    unless bootstrap_role and node_count
      raise "please define `bootstrap_role` and `node_count` in your configure_prison routine"
    end

    @prison, @ips, @node_names = vagrant_bootstrap(bootstrap_role, node_count)
  end
  
  def teardown
    super
    vagrant_cleanup(@prison, @node_names)
  end
end
