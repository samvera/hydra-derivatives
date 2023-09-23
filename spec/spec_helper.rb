# frozen_string_literal: true
ENV['environment'] ||= 'test'
ENV['RAILS_ENV'] = 'test'

require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter
  ]
)
SimpleCov.minimum_coverage 100
SimpleCov.start do
  add_filter '/spec'
end

# - RSpec adds ./lib to the $LOAD_PATH
require 'hydra/derivatives'
# Resque.inline = Rails.env.test?
require 'pry-byebug' unless ENV['CI']

require 'active_fedora/cleaner'
ActiveFedora::Base.logger = Logger.new(STDOUT)
RSpec.configure do |config|
  config.before(:each) do
    ActiveFedora::Cleaner.clean!
  end
end
if ENV['FCREPO_CONFIG_PATH']
  ActiveFedora.init(fedora_config_path: ENV['FCREPO_CONFIG_PATH'])
end

# Workaround for RAW image support until these are pushed upstream to
# the MIME Types gem
require 'mime-types'
dng_format = MIME::Type.new('image/x-adobe-dng')
dng_format.extensions = 'dng'
MIME::Types.add(dng_format)

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end
