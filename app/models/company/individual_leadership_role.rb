module Company
  class IndividualLeadershipRole < ::Company::Base
    self.table_name = "individual_process_type"
    belongs_to :leadership_role, foreign_key: :process_type_id
    belongs_to :individual
    belongs_to :campus, class_name: Church::Campus
    belongs_to :role, class_name: Company::LeadershipRole

    def self.for_individual(individual)
      individual = Church::Individual.find(individual) if individual.is_a?(Numeric)

      joins(:individual).references(:individual).where(individual: {app_individual_id: individual.id})
    end
  end
end
