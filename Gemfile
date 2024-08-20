# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in browse_everything.gemspec
gemspec

# == Extra dependencies for dummy test app ==
#
# Extra dependencies for dummy test app are in .gemspec as a development dependency
# where possible. But when  dependencies vary for different versions
# of Rails, rails-version-specific dependencies are here, behind conditionals, for now.
#
# TODO switch to use appraisal gem instead, encapsulating these different additional
# dependencies per Rails version, as well as method of choosing operative rails version.
#
# We allow testing under multiple versions of Rails by setting ENV RAILS_VERSION,
# used in CI, can be used locally too.

# Set a default RAILS_VERSION so we make sure to get extra dependencies for it...

ENV['RAILS_VERSION'] ||= "6.1.6"

if ENV['RAILS_VERSION']
  if ENV['RAILS_VERSION'] == 'edge'
    gem 'rails', github: 'rails/rails'
  else
    gem 'rails', ENV['RAILS_VERSION']
  end

group :development, :test do
  gem 'bixby'
  gem 'rspec_junit_formatter'
  gem 'simplecov'
end
