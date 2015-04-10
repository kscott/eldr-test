module Church
  class IndividualPosition < ::Church::Base
    self.table_name = "individual_positions"
    self.primary_keys = :individual_id, :position_id
    belongs_to :position
    belongs_to :individual

    enum status_id: [:requesting, :filled_in_past, :fills_currently, :informed, :declined, :undecided]
    alias_attribute :status, :status_id
  end
end
