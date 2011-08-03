require 'bundler'
Bundler::GemHelper.install_tasks
require 'rake'
require 'rake/testtask'
require 'rdoc/task'

# Gem managment tasks.
#
# == Git tag & push to origin/master and push gem to Rubygems.org:
#
#   $ rake release
#

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the plugin.'
Rake::TestTask.new(:test) do |test|
  test.libs = ['lib', 'test']
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

desc 'Generate documentation for the plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.main = 'README.textile'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.textile')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
