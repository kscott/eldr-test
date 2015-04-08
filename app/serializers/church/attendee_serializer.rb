module Church
  class AttendeeSerializer < ::Church::BaseSerializer
    schema do
      type "attendee"
      basic_individual_profile item.individual
    end
  end
end
