module Church
  class CheckinSetupSerializer < ::Church::BaseSerializer
    schema do
      type "checkin_setup"

      map_properties :id, :name, :station_type, :background_image, :label_quantity, :label_type
      entities :events, item.events_for, Church::EventOccurrenceSerializer
      entity :campus, item.campus, Church::BasicCampusSerializer
    end
  end
end
