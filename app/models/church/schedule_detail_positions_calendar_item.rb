module Church
  class ScheduleDetailPositionsCalendarItem < ::Church::Base
    self.table_name = "schedule_detail_positions_calendar_items"
    belongs_to :schedule_detail_assignment
    belongs_to :schedule_detail_calendar_item
  end
end
