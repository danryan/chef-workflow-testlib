require 'chef-workflow/minitest-helper'
require 'chef-workflow/test-case/vagrant'
require 'minitest/unit'

class MiniTest::Unit::TestCase
  include MiniTest::Assertions::RemoteChef
end

require 'minitest/autorun'
