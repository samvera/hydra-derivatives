ENV['environment'] ||= 'test'
# - RSpec adds ./lib to the $LOAD_PATH
require 'hydra/derivatives'
#Resque.inline = Rails.env.test?
require 'byebug' unless ENV['TRAVIS']

require 'active_fedora/cleaner'
RSpec.configure do |config|
  config.before(:each) do
    ActiveFedora::Cleaner.clean!
  end
end

$in_travis = !ENV['TRAVIS'].nil? && ENV['TRAVIS'] == 'true'
