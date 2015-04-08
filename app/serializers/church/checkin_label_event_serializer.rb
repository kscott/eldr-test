module Church
  class CheckinLabelEventSerializer < ::Church::BaseSerializer
    schema do
      type "checkin_label_event"
      properties do |p|
        p.time item.time
        p.room_name item.event.checkin_display_name
        p.group_name item.event.group_name
        p.event_id item.event.id
      end
    end
  end
end
