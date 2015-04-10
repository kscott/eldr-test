module Church
  class PositionStyle < ::Church::Base
    self.table_name = "position_styles"
    belongs_to :position
    belongs_to :style
  end
end
