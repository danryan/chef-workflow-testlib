require 'chef/search/query'
require 'chef/config'

module ChefHelper
  def perform_search(type, query)
    Chef::Search::Query.new.search(type, query).first.map(&:name)
  end
end
