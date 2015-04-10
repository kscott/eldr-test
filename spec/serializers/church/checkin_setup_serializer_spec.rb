describe Church::CheckinSetupSerializer do
  let(:setup) { Church::CheckinSetup.last }
  subject(:serializer) { described_class.new(setup).to_hash }

  it "has an id" do
    expect(subject[:id]).to eq(setup.id)
  end
  it "has a name" do
    expect(subject[:name]).to eq(setup.name)
  end
  it "has events" do
    expect(subject.key?(:events)).to be_truthy
  end
end
