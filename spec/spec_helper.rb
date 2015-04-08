require "rubygems"
require "bundler"

Bundler.require

require "dotenv"
Dotenv.load

require 'rack/test'
require 'rack'

$LOAD_PATH.unshift File.join(__dir__, "..")
require_all(File.join(__dir__, "..", "app"))

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.pattern = '**{,/*/**}/*_spec.rb'
end
