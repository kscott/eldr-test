class User
  def initialize(individual_id)
    @individual = Church::Individual.find(individual_id)
  end

  def leads?(individual)
    @individual.leads?(individual)
  end
end
