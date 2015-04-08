module Church
  class CheckinFailureSerializer < ::Church::BaseSerializer
    schema do
      type "checkin_failure"
      properties do |p|
        p.individual_id item.id
        p.event_id item.events.first.id
        p.status item.checkin_action
        p.failure_type item.checkin_failure_type
      end
    end
  end
end
