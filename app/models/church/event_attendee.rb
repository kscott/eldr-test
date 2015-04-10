module Church
  class EventAttendee < ::Church::Base
    self.primary_keys = :individual_id, :event_id, :occurrence

    before_save :set_engagement_week

    belongs_to :event
    belongs_to :individual
    belongs_to :engagement_week
    belongs_to :checkin

    def self.for_occurrence(event_id, date)
      includes(:individual).where("event_id = :event_id AND DATE(occurrence) = :occurrence", event_id: event_id, occurrence: date.strftime("%Y-%m-%d"))
    end

    def self.for_date(date)
      includes(:individual).where("DATE(occurrence) = :occurrence", occurrence: date.strftime("%Y-%m-%d"))
    end

    def self.for_date_time(datetime)
      includes(:individual).where("occurrence = :occurrence", occurrence: datetime.strftime("%Y-%m-%d %H:%M:%S"))
    end

    def self.has_individual_attendance?(individual, occurrence)
      where("individual_id = :individual_id AND occurrence = :occurrence", individual_id: individual.id, occurrence: occurrence.strftime("%Y-%m-%d %H:%M:%S")).size > 0
    end

    def self.individual_is_attending?(individual, event, occurrence)
      where("individual_id = :individual_id AND event_id = :event_id AND occurrence = :occurrence", individual_id: individual.id, event_id: event.id, occurrence: occurrence.strftime("%Y-%m-%d %H:%M:%S")).size > 0
    end

    def self.event_attendance_by_occurrence(event_ids, starting, ending)
      where(occurrence: starting..ending, event_id: event_ids).group(:event_id, :occurrence).sum(:quantity)
    end

    def self.security_codes_for_date(date = Time.now)
      where("DATE(occurrence) = :occurrence", occurrence: date.strftime("%Y-%m-%d")).where.not(security_code: "").pluck(:security_code).uniq
    end

    def self.family_security_codes_for_date(family_ids, date = Time.now)
      where("individual_id IN (:family_ids) AND DATE(occurrence) = :occurrence", family_ids: family_ids, occurrence: date.strftime("%Y-%m-%d")).where.not(security_code: "").pluck(:security_code).uniq
    end

    def set_engagement_week
      if occurrence_changed?
        self.engagement_week = Company::OrganizationApplication.current.engagement_week_for(occurrence)
      end
    end
  end
end
