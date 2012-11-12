require 'chef-workflow/knife-helper'
require 'chef-workflow/vagrant-helper'
require 'minitest'

class MiniTest::Unit::TestCase
  include VagrantHelper
end
