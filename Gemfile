source 'https://rubygems.org'

# Please see hydra-derivatives.gemspec for dependency information.
gemspec

group :development, :test do
  gem 'simplecov'
  gem 'coveralls'
  gem 'byebug' unless ENV['TRAVIS']
  gem 'rubocop', '~> 0.37.2', require: false
  gem 'rubocop-rspec', require: false
end
