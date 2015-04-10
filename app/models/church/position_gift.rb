module Church
  class PositionGift < ::Church::Base
    self.table_name = "position_gifts"
    belongs_to :position
    belongs_to :spiritual_gift, foreign_key: :gift_id
  end
end
