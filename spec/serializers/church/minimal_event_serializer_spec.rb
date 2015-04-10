describe Church::MinimalEventSerializer do
  let(:event) { Church::Event.find(89) }
  subject(:serializer) { described_class.new(event).to_hash }

  it "has an id" do
    expect(subject[:id]).to eq(event.id)
  end
  it "has a name" do
    expect(subject[:name]).to eq(event.name)
  end
  it "has a room_ratio" do
    expect(subject[:room_ratio]).to eq(event.room_ratio)
  end
  it "has a checkin_display_name" do
    expect(subject[:checkin_display_name]).to eq(event.checkin_display_name)
  end
  it "has a group" do
    expect(subject.key?(:group)).to be_truthy
  end
  it "gives the event name when room description is empty" do
    event.stub(:room_description).and_return("")
    expect(subject[:checkin_display_name]).to eq(event.name)
  end
end
