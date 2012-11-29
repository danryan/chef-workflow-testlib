require 'chef-workflow'
require 'chef-workflow/helpers/minitest'
require 'chef-workflow/test-case/vagrant'
require 'minitest/unit'

class MiniTest::Unit::TestCase
  include MiniTest::Assertions::RemoteChef
end

require 'minitest/autorun'
