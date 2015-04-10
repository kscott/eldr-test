describe Church::NeedSerializer do
  let(:need) { Church::Need.find(6) }
  subject(:serialized_need) { described_class.new(need).to_hash }

  it "has an id" do
    expect(subject[:id]).to eq(need.id)
  end
  it "has a name" do
    expect(subject[:name]).to eq(need.name)
  end
  it "has a description" do
    expect(subject[:description]).to eq(need.description)
  end
  context "belongs to a group" do
    let(:group) { need.group }
    subject(:serializer) { serialized_need[:group] }
    it_behaves_like "a basic group profile" do
      let(:expected) { group }
    end
  end
  context "has a coordinator" do
    let(:expected) { need.coordinator }
    subject { serialized_need[:coordinator] }
    it_behaves_like "a basic individual profile"
  end
  it "has items" do
    expect(subject.key?(:items)).to be_truthy
  end
end
