module Church
  class ScheduleDetailPosition < ::Church::Base
    self.table_name = "schedule_detail_positions"
    belongs_to :schedule_detail_assignment
    belongs_to :schedule_detail
    belongs_to :position
    has_and_belongs_to_many :schedule_detail_calendar_items, join_table: :schedule_detail_positions_calendar_items, foreign_key: :schedule_detail_positions_id
  end
end
