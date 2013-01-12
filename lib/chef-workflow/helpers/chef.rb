require 'chef/search/query'
require 'chef/config'

#
# Small helper library, intended to be mixed into others that provides short
# helpers for doing complicated things with the Chef API.
#
module ChefHelper
  #
  # Perform a search and return the names of the nodes that match the search.
  #
  def perform_search(type, query)
  	Chef::Config.from_file(KnifeSupport.singleton.knife_config_path)
    Chef::Search::Query.new.search(type, query).first.map(&:name)
  end
end
