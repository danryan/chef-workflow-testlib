require 'chef-workflow/helpers/chef'
require 'minitest/unit'

module MiniTest::Assertions::RemoteChef
  include ChefHelper

  def assert_search(type, query, node_names)
    assert_equal(node_names.sort, perform_search(type, query).sort)
  end

  def refute_search(type, query, node_names)
    refute_equal(node_names.sort, perform_search(type, query).sort)
  end

  def assert_search_count(type, query, count)
    assert_equal(count, perform_search(type, query).count)
  end

  def refute_search_count(type, query, count)
    refute_equal(count, perform_search(type, query).count) 
  end
end
