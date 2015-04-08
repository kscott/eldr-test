require "rubygems"
require "bundler"

Bundler.require
Dotenv.load

$LOAD_PATH.unshift __dir__
require_all(File.join(__dir__, "app"))

run Api::Base
