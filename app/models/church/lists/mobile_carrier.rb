module Church
  module Lists
    class MobileCarrier < ::Church::Base
      belongs_to :individual
      self.table_name = "z_sms_carrier"
    end
  end
end
