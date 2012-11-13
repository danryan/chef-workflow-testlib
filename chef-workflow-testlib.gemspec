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
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'chef-workflow-tasklib'
  gem.add_dependency 'minitest'
end
