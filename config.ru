require "rubygems"
require "bundler"

Bundler.require
Dotenv.load

$LOAD_PATH.unshift __dir__
$LOAD_PATH.unshift File.join(__dir__, "lib")

require_rel(File.join(__dir__, "lib"), File.join(__dir__, "app"))
require_rel(File.join(__dir__, "config/initializers"))

run Api::Base
