require "bundler/gem_tasks"

require 'rdoc/task'

RDoc::Task.new do |r|
  r.main = "README.md"
  r.rdoc_files.include(r.main, "LICENSE.txt", "lib/**/*.rb")
  r.options << "--all"
end
