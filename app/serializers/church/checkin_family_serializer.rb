module Church
  class CheckinFamilySerializer < ::Church::BaseSerializer
    schema do
      type "checkin_family"
      map_properties :family_name
      entity :primary_contact, item.primary_contact, Church::CheckinIndividualSerializer
      entity :spouse, item.spouse, Church::CheckinIndividualSerializer
      entities :children, item.children, Church::CheckinIndividualSerializer
      entities :others, item.others, Church::CheckinIndividualSerializer
    end
  end
end
