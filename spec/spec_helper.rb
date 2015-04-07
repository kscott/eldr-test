require "rubygems"
require "bundler"

Bundler.require

require "dotenv"
Dotenv.load

require 'rack/test'
require 'rack'
require_relative "../app"

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.pattern = '**{,/*/**}/*_spec.rb'
end
