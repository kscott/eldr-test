module Email
  class Base < ::ActiveRecord::Base
    self.abstract_class = true
    # self.establish_connection "email_#{Rails.env}".to_sym
  end
end
