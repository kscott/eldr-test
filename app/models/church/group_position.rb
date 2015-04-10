module Church
  class GroupPosition < ::Church::Base
    self.table_name = "group_positions"
    belongs_to :position
    belongs_to :group
  end
end
