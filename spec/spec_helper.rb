require "rubygems"
require "bundler"
require "pry"

Bundler.require

require "dotenv"
Dotenv.load

require 'rack/test'
require 'rack'

$LOAD_PATH.unshift File.join(__dir__, "..")
$LOAD_PATH.unshift File.join(__dir__, "lib")
require_all(File.join(__dir__, "..", "app"), File.join(__dir__, "..", "lib"))
require_all(File.join(__dir__, "../config/initializers"))

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(__dir__, "..", "spec", "support", "**", "*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.pattern = '**{,/*/**}/*_spec.rb'
end
