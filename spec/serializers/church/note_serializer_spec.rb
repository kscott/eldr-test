describe Church::NoteSerializer do
  before(:all) do
    @individual = Church::Individual.find(79)
  end

  let (:visible_notes) { @individual.notes }
  subject (:serializer) { described_class.new(visible_notes.first, current_individual: Church::Individual.find(1)).to_hash }

  it "has an id" do
    expect(serializer[:id]).to eq(visible_notes.first.id)
  end
  it "has a type" do
    expect(serializer[:type]).to eq(visible_notes.first.context)
  end
  it "has a context" do
    expect(serializer[:process_queue]).to_not be_empty
  end
  it "has content" do
    expect(serializer[:content]).to eq(visible_notes.first.note)
  end
  it "has a creator" do
    expect(serializer[:creator]).to_not be_empty
  end
end
