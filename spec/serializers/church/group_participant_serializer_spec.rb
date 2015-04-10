describe Church::GroupParticipantSerializer do
  let(:individual_group) { Church::IndividualGroup.find_by(individual_id: 25, group_id: 7) }
  subject (:serializer) { described_class.new(individual_group).to_hash }

  it_behaves_like "a basic individual profile" do
    let(:expected) { individual_group.individual }
  end
  it_behaves_like "a basic family profile" do
    let (:expected) { individual_group.individual }
  end
  it_behaves_like "an individual with basic links" do
    let (:expected) { individual_group.individual }
  end

  it "has a group_id" do
    expect(serializer[:group_id]).to eq(individual_group.group_id)
  end

  it "has a status" do
    expect(serializer[:status]).to eq(individual_group.status)
  end
end
