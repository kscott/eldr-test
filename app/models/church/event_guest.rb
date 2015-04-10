module Church
  class EventGuest < ::Church::Base
    default_scope { joins(:individual) }
    self.table_name = "individual_events"
    self.primary_keys = :individual_id, :event_id

    enum status_id: [:requesting, :attended, :attending, :invited, :declined, :undecided]
    alias_attribute :status, :status_id

    belongs_to :event
    belongs_to :individual

    def self.response_for_individual(event_id, individual_id)
      where(event_id: event_id, individual_id: individual_id).first
    end

    def self.attending
      where(status_id: Church::EventGuest.status_ids[:attending])
    end

    def self.by_attending
      joins(:individual).merge(EventGuest.attending)
    end

    def printable_status
      case status
      when "attending"
        "Yes"
      when "declined"
        "No"
      when "undecided"
        "Maybe"
      else
        "Unknown"
      end
    end
  end
end
