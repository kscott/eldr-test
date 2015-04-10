module Church
  class IndividualGroup < ::Church::Base
    self.table_name = "individual_groups"
    self.primary_keys = :group_id, :individual_id
    belongs_to :group
    belongs_to :individual

    scope :is_leader, -> { where(status_id: Church::IndividualGroup.status_ids[:leader]) }

    enum status_id: [:requesting, :leader, :member, :invited]

    alias_attribute :status, :status_id

    def participant?
      leader? || member?
    end

    def self.individual_is_participant?(individual, group)
      where(individual_id: individual.id, group_id: group.id, status_id: [1,2]).size > 0
    end
  end
end
