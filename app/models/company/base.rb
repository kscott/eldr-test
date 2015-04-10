module Company
  class Base < ::ActiveRecord::Base
    self.abstract_class = true
    config = ::DatabaseManagement.configuration["company_#{ENV["APP_ENV"]}"]
    self.establish_connection config
  end
end
