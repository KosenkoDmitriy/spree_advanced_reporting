require 'rake'
require 'rake/testtask'
require 'rake/packagetask'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'spree_core/testing_support/common_rake'

RSpec::Core::RakeTask.new
Cucumber::Rake::Task.new

task default: [:spec, :cucumber]

spec = eval(File.read('advanced_reporting.gemspec'))

desc 'Generates a dummy app for testing'
task :test_app do
  ENV['LIB_NAME'] = 'advanced_reporting'
  Rake::Task['common:test_app'].invoke
end
