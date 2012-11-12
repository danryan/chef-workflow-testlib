require 'chef-workflow/knife-helper'
require 'chef-workflow/vagrant-helper'
require 'minitest/unit'

class MiniTest::Unit::TestCase
  include VagrantHelper
end

require 'minitest/autorun'
