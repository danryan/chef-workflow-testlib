require 'chef-workflow'
require 'chef-workflow/helpers/minitest'
require 'chef-workflow/test-case/ec2'
require 'chef-workflow/test-case/vagrant'
require 'chef-workflow/test-case/chef'
require 'minitest/unit'

class MiniTest::Unit::TestCase
  include MiniTest::Assertions::RemoteChef
end

require 'chef-workflow/runner/provisioned'
require 'minitest/autorun'
