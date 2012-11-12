require 'chef-workflow/knife-support'
require 'chef/search/query'
require 'chef/config'

module ChefHelper
  def configure_chef
    Chef::Config.from_file(KnifeSupport.singleton.knife_config_path)
  end

  def perform_search(type, query)
    configure_chef
    Chef::Search::Query.new.search(type, query).first.map(&:name)
  end
end
