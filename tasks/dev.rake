# frozen_string_literal: true

namespace :server do
  desc "Start solr and fedora servers for testing"
  task :start do
    require 'rails'
    `lando start`
    puts "Started Solr/Fedora"
  end

  desc "Cleanup test servers"
  task :clean do
    require 'rails'
    `lando destroy -y`
    `lando start`
    puts "Cleaned/Started Solr/Fedora"
  end

  desc "Stop test servers"
  task :stop do
    `lando stop -y`
  end
end
