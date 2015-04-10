module Church
  class ScheduleDetailCalendarItem < ::Church::Base
    self.table_name = "schedule_detail_calendar_items"
    has_and_belongs_to_many :schedule_detail_positions, join_table: :schedule_detail_positions_calendar_items
    scope :service_times, -> { where(service_time: "1") }
    scope :other_times, -> { where.not(service_time: "1") }

    def label
      if service_time?
        "Service"
      else
        name
      end
    end

    def service_time?
      service_time == "1"
    end

    def display_time
      datetime_start.strftime("%l:%M %p").strip
    end

    def display
      "#{label}: #{display_time}"
    end
  end
end
