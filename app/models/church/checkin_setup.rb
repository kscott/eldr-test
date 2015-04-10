module Church
  class CheckinSetup < ::Church::Base
    self.table_name = "checkin_setup"
    belongs_to :campus
    has_many :checkin_setup_event_times, foreign_key: :setup_id
    has_many :checkin_setup_event_criteria, foreign_key: :setup_id
    default_scope -> { where.not(limited: "1") }
    scope :manual, -> { where(limited: "1") }

    def self.by_type(type)
      if type == :all
        self.all
      else
        where(station_type: type.to_s)
      end
    end

    def url
      "/checkin_login.php?tk=#{token}"
    end

    def times
      checkin_setup_event_times.map(&:to_s)
    end

    def criteria
      checkin_setup_event_criteria
    end

    def events_for(date = Time.now)
      matching = []
      criteria.each do |crit|
        matching << checkin_setup_event_times.map {|time| crit.events.merge(Church::Event.starting_at(time.start_time).all)}
      end

      matching.flatten!.uniq!
      matching.map {|event| event.occurrences(date)}.flatten.sort! { |a,b| a.occurrence <=> b.occurrence }
    end
  end
end
