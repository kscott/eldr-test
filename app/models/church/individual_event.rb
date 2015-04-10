module Church
  class IndividualEvent < ::Church::Base
    self.table_name = "individual_events"
    belongs_to :event
    belongs_to :individual

    enum status_id: [:requesting, :attended, :attending, :invited, :declined, :undecided]
    alias_attribute :status, :status_id
  end
end
