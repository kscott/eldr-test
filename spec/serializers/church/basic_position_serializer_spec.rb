describe Church::BasicPositionSerializer do
  let(:position) { Church::Position.find(6) }
  subject { described_class.new(position).to_hash }

  it "has an id" do
    expect(subject[:id]).to eq(position.id)
  end

  it "has a name" do
    expect(subject[:name]).to eq(position.name)
  end

  it "has a group" do
    expect(subject[:group]).to_not be_nil
  end

  it "has spiritual gifts" do
    expect(subject.key?(:spiritual_gifts)).to be_truthy
  end

  it "has styles" do
    expect(subject.key?(:styles)).to be_truthy
  end
end
