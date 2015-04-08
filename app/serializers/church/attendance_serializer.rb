module Church
  class AttendanceSerializer < ::Church::BaseSerializer
    schema do
      type "attendance"
      map_properties :event_id, :occurrence, :status, :head_count
      property :visitors, item.head_count
      property :total_attendance, total_attendance
      entity :summary, item.summary, Church::SummarySerializer
      entities :attendees, item.attendees, Church::AttendeeSerializer
      entity :event, item.event, Church::BasicEventSerializer
      property :send_to_options, AttendanceSendToOptionsPolicy.new(Company::OrganizationApplication.current).evaluate
    end

    def total_attendance
      item.head_count + item.attendees.to_a.size
    end
  end
end
