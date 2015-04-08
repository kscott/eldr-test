module Church
  class CheckinIndividualSerializer < ::Church::BaseSerializer
    schema do
      type "checkin_individual"
      basic_individual_profile item
      entities :events, item.events, Church::CheckinEventSerializer
    end
  end
end
