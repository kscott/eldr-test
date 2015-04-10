module Church
  class Merchant < ::Church::Base
    self.table_name = 'campus_merchant'
    belongs_to :campus
    belongs_to :merchant_type

    def allow_credit_card?
      merchant_type.credit_card?
    end

    def allow_ach?
      merchant_type.ach?
    end
  end
end
