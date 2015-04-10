describe Church::NeedItemSerializer do
  let(:need_item) { Church::NeedItem.find(97) }
  subject(:serialized_need_item) { described_class.new(need_item).to_hash }

  it "has an id" do
    expect(subject[:id]).to eq(need_item.id)
  end
  it "has a name" do
    expect(subject[:name]).to eq(need_item.name)
  end
  it "has a date" do
    expect(subject[:date]).to eq(need_item.date)
  end
  context "has an assigned individual" do
    let(:expected) { need_item.assigned_to }
    subject { serialized_need_item[:assigned_to] }
    it_behaves_like "a basic individual profile"
  end
end
