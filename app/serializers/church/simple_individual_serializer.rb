module Church
  class SimpleIndividualSerializer < ::Church::BaseSerializer
    schema do
      type "individual"
      basic_individual_profile item
    end
  end
end
