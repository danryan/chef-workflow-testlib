require 'chef-workflow/helpers/chef'
require 'minitest/unit'

#
# Small assertion library for minitest to assist with remote chef tests.
#
module MiniTest::Assertions::RemoteChef
  include ChefHelper

  #
  # Assert that a search included the node names.
  #
  def assert_search(type, query, node_names)
    assert_equal(node_names.sort, perform_search(type, query).sort)
  end

  #
  # Refute that a search included the node names.
  #
  def refute_search(type, query, node_names)
    refute_equal(node_names.sort, perform_search(type, query).sort)
  end

  #
  # Assert the search included `count` elements. Does not verify what that
  # count is of.
  #
  def assert_search_count(type, query, count)
    assert_equal(count, perform_search(type, query).count)
  end

  #
  # Refute the search included `count` elements. Does not verify what that
  # count is of.
  #
  def refute_search_count(type, query, count)
    refute_equal(count, perform_search(type, query).count) 
  end
end
