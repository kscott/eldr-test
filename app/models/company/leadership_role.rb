module Company
  class LeadershipRole < ::Company::Base
    self.table_name = "z_process_type"
    self.inheritance_column = nil
    has_many :individual_leadership_roles, class_name: IndividualLeadershipRole, foreign_key: :process_type_id
    has_many :leaders, through: :individual_leadership_roles, class_name: Individual, source: :individual
    scope :active, -> { where.not(inactive: 1) }

    def self.for_individual(individual)
      active.joins(:individual_leadership_roles).references(:individual_leadership_roles).merge(IndividualLeadershipRole.for_individual(individual))
    end

    alias_attribute :title, :name
    alias_attribute :identifier, :short_name
    def link
      "/#{short_name.gsub(/^ldr_/, "")}"
    end
  end
end
