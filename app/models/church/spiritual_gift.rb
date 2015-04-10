module Church
  class SpiritualGift < ::Church::Base
    self.table_name = "gift"
    belongs_to :position
  end
end
