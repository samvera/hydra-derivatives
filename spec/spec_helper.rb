ENV['environment'] ||= 'test'
# - RSpec adds ./lib to the $LOAD_PATH
require 'hydra/derivatives'
#Resque.inline = Rails.env.test?
require 'byebug' unless ENV['TRAVIS']

require 'active_fedora/cleaner'
ActiveFedora::Base.logger = Logger.new(STDOUT)
RSpec.configure do |config|
  config.before(:each) do
    ActiveFedora::Cleaner.clean!
  end
end

$in_travis = !ENV['TRAVIS'].nil? && ENV['TRAVIS'] == 'true'

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end
