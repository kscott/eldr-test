describe Church::AttendeeSerializer do
  let(:attendee) { Church::EventAttendee.find_by(individual_id: 38) }
  subject(:serializer) {described_class.new(attendee).to_hash}

  it_behaves_like "a basic individual profile" do
    let(:expected) {attendee.individual}
  end
end
