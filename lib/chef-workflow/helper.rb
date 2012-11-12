require 'chef-workflow/knife-helper'
require 'chef-workflow/vagrant-helper'
require 'chef-workflow/minitest-helper'
require 'minitest/unit'

class MiniTest::Unit::TestCase
  include VagrantHelper
  include MiniTest::Assertions::RemoteChef
end

require 'minitest/autorun'
