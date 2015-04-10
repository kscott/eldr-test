describe Church::MyGroupSerializer do
  let(:group) { Church::Group.find(33) }
  subject(:serializer) { described_class.new(group).to_hash }

  it_behaves_like "a basic group profile" do
    let(:expected) { group }
  end

  it "has a status" do
    allow(group).to receive(:individual_status).and_return("leader")
    expect(serializer[:status]).to eq("leader")
  end
end
