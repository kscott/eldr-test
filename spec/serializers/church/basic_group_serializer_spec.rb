describe Church::BasicGroupSerializer do
  let(:group) { Church::Group.find(33) }
  subject(:serializer) { described_class.new(group).to_hash }

  it_behaves_like "a basic group profile" do
    let(:expected) { group }
  end
end
