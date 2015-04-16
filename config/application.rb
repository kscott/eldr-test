require "bundler"
require "dotenv"

Bundler.require
Dotenv.load

APP_ROOT = File.join(__dir__, "..")

$LOAD_PATH.unshift APP_ROOT
$LOAD_PATH.unshift File.join(APP_ROOT, "lib")

require_all(File.join(APP_ROOT, "lib"), File.join(APP_ROOT, "app"))
require_all(File.join(APP_ROOT, "config/initializers"))

