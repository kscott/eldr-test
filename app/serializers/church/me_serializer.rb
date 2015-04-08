module Church
  class MeSerializer < ::Church::BaseSerializer
    schema do
      type "individual"
      basic_individual_profile item
      basic_family_profile item
      basic_individual_links item
    end
  end
end
