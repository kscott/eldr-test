module Church
  class GroupEvent < ::Church::Base
    self.table_name = "group_events"
    belongs_to :event
    belongs_to :group
  end
end
