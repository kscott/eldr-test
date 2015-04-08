module Church
  class MeetingSerializer < ::Church::BaseSerializer
    schema do
      type "meeting"
      map_properties :id, :name, :day_of_week, :attendance_taken, :total_attendees
      property :occurrence, item.occurrence.strftime("%Y-%m-%d %H:%M:%S")
    end
  end
end
