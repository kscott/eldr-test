require "rubygems"
require "bundler"
require "pry"

Bundler.require

require "dotenv"
Dotenv.load

require 'rack/test'
require 'rack'

require 'active_support/testing/time_helpers'

require_relative "../config/application"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(__dir__, "..", "spec", "support", "**", "*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.pattern = '**{,/*/**}/*_spec.rb'

  # config.treat_symbols_as_metadata_keys_with_true_values = true
  # config.run_all_when_everything_filtered = true

  # config.include ActiveSupport::Testing::TimeHelpers
  config.order = "random"

  # config.expect_with :rspec do |c|
  #   c.syntax = :expect
  # end
end

org = Company::OrganizationApplication.find_by_subdomain(ENV["INTEGRATION_TEST_SUBDOMAIN"])
DatabaseManagement::connect_to_church_database org
Company::OrganizationApplication.current = org
Church::Individual.current = Church::Individual.find(1)

