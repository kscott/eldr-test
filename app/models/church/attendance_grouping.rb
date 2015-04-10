module Church
  class AttendanceGrouping < ::Church::Base
    self.table_name = "event_grouping"
    has_many :events, foreign_key: :grouping_id

    def attendance_for_range(range_start, range_end = Time.now, campus = nil)
      attendance = events.joins(:attendees).where(event_attendees: {occurrence: [range_start.beginning_of_day..range_end.end_of_day]})
      attendance = attendance.joins(:groups).where(groups: {campus_id: campus}) unless campus.nil?
      attendance.sum(:quantity)
    end
  end
end
