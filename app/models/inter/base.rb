module Inter
  class Base < ::ActiveRecord::Base
    self.abstract_class = true
    # self.establish_connection "inter_#{Rails.env}".to_sym
  end
end
