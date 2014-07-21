ENV['environment'] ||= 'test'
# - RSpec adds ./lib to the $LOAD_PATH
require 'hydra/derivatives'
#Resque.inline = Rails.env.test?
require 'byebug' unless ENV['TRAVIS']

RSpec.configure do |config|
end

$in_travis = !ENV['TRAVIS'].nil? && ENV['TRAVIS'] == 'true'
