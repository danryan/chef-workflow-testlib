# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chef-workflow-testlib/version'

Gem::Specification.new do |gem|
  gem.name          = "chef-workflow-testlib"
  gem.version       = Chef::Workflow::Testlib::VERSION
  gem.authors       = ["Erik Hollensbe"]
  gem.email         = ["erik+github@hollensbe.org"]
  gem.description   = %q{Test helpers and assertions for chef-workflow}
  gem.summary       = %q{Test helpers and assertions for chef-workflow}
  gem.homepage      = "https://github.com/chef-workflow/chef-workflow-testlib"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'chef-workflow', '~> 0.1.0'
  gem.add_dependency 'minitest', '~> 4.3.0'
  gem.add_dependency 'net-ssh', '~> 2.2.2'

  gem.add_development_dependency 'rdoc'
  gem.add_development_dependency 'rake'
end
