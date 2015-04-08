module Church
  class BasicIndividualSerializer < ::Church::BaseSerializer
    schema do
      type "basic-individual"
      basic_individual_profile item
      basic_family_profile item
      basic_individual_links item
    end
  end
end
