module Church
  class MerchantType < ::Church::Base
    self.table_name = 'z_merchant_type'
  end

  def credit_card?
    case code.to_s
    when :bp
      true
    when :ps
      false
    else
      false
    end
  end

  def ach?
    case code.to_s
    when :bp
      true
    when :ps
      true
    else
      false
    end
  end
end
