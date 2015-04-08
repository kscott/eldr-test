module Church
  class CheckinEventSerializer < ::Church::BaseSerializer
    schema do
      type "checkin_event"
      map_properties :id, :name, :status
      properties do |p|
        p.occurrence item.occurrence.to_time
      end
    end
  end
end
