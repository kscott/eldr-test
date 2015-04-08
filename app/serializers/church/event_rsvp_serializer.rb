module Church
  class EventRsvpSerializer < ::Church::BaseSerializer
    schema do
      type "rsvp"
      map_properties :status, :quantity
      property :message, item.comment
      entity :individual, item.individual, Church::BasicIndividualSerializer
      entity :event, item.event, Church::BasicEventSerializer
    end
  end
end
