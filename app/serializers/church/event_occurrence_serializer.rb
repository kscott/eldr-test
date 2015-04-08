module Church
  class EventOccurrenceSerializer < ::Church::BaseSerializer
    schema do
      type "occurrence"
      map_properties :occurrence, :name, :day_of_week, :time
      entity :event, item.event, Church::MinimalEventSerializer
    end
  end
end
