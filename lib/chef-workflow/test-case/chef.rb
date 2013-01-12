require 'chef-workflow/test-case/vagrant'
require 'chef-workflow/helpers/vagrant_ssh'

#
# ProvisionedTestCase that uses VagrantProvisionHelper.
#
class MiniTest::Unit::ChefTestCase < MiniTest::Unit::VagrantTestCase
  include VagrantSSHHelper
  extend VagrantSSHHelper
end
