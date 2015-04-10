module Church
  class EventSummary < ::Church::Base
    belongs_to :event
    self.primary_keys = :event_id, :occurrence

    serialize :email_date_last_sent, ::CustomDateTimeSerializer
    self.table_name = 'event_summary'

    before_validation :set_email_date_last_sent

    def occurrence
      event.timezone.local_to_utc(read_attribute(:occurrence)).in_time_zone(event.timezone)
    end

    def set_email_date_last_sent
      self.email_date_last_sent = "" unless self.email_date_last_sent
    end

    enum status_id: [:not_reported, :complete, :did_not_meet]
    EMAIL_TO_STATUS = {
      none: "",
      leaders: "l",
      participants: "e"
    }

    alias_attribute :status, :status_id
    alias_attribute :notes, :notes_general
    alias_attribute :prayer_requests, :notes_prayer_praise
    alias_attribute :people_information, :notes_people

    def attendance_taken?
      complete? || did_not_meet?
    end

    def total_attendance
      attendance = Church::EventAttendee.event_attendance_by_occurrence([event_id], occurrence.beginning_of_day, occurrence.end_of_day)
      attendance.values.first
    end

    def self.for_occurrence(event_id, date)
      where("event_id = :event_id AND DATE(occurrence) = :occurrence", event_id: event_id, occurrence: date.strftime("%Y-%m-%d")).first
    end

    def self.summaries_for_events(event_ids, starting, ending)
      where(occurrence: starting..ending, event_id: event_ids)
    end
  end
end
