require "rubygems"
require "bundler"

require_relative "config/application"

use ActiveRecord::ConnectionAdapters::ConnectionManagement
run Api::Base
