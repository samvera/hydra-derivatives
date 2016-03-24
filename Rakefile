#!/usr/bin/env rake

require "bundler/gem_tasks"

# Dir.glob('tasks/*.rake').each { |r| import r }

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'solr_wrapper/rake_task'
require 'fcrepo_wrapper'
require 'active_fedora/rake_support'

desc 'Start Fedora and Solr and run specs'
task :ci do
  with_test_server do
    Rake::Task['spec'].invoke
  end
end
task default: :ci
