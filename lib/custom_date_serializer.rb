class CustomDateSerializer
  def self.dump(value)
    if value.is_a?(String) && value.empty?
      "0000-00-00"
    elsif value.is_a?(Time)
      value.strftime('%Y-%m-%d')
    elsif value.is_a?(Date)
      value.strftime('%Y-%m-%d')
    else
      value.to_s
    end
  end

  def self.load(value)
    value
  end
end
