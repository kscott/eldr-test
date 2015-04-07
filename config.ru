require "rubygems"
require "bundler"

Bundler.require

Dotenv.load

require_relative 'app'

# run App
#
run API
