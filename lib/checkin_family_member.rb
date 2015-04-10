class CheckinFamilyMember
  attr_accessor :events, :checkin_action, :checkin_failure_type, :checkin
  def initialize(individual)
    @member = individual
    @events = []
    @checkin_failure_type = :none
  end

  def add_events_for_checkin(events)
    events.each do |occurrence|
      if Church::IndividualGroup.individual_is_participant?(self, occurrence.event.group)
        checkin_event = Church::Checkin::Event.new(occurrence)
        if Church::EventAttendee.individual_is_attending?(self, occurrence.event, occurrence.to_time)
          checkin_event.status = :attending
        end
        self.events << checkin_event
      end
    end
  end

  def method_missing(method_name, *args, &block)
    @member.send(method_name, *args, &block)
  end
end
