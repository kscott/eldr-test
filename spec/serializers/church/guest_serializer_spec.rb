describe Church::GuestSerializer do
  let(:guest) { Church::EventGuest.find_by(individual_id: 3, event_id: 16) }
  subject(:serializer) {described_class.new(guest).to_hash}

  it_behaves_like "a basic individual profile" do
    let(:expected) {guest.individual}
  end
end
