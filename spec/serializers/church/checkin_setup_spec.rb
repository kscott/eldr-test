describe Church::CheckinSetupSerializer do
  let(:setup) { Church::CheckinSetup.first }
  subject(:serialized_setup) { described_class.new(setup).to_hash }

  it "has an id" do
    expect(subject[:id]).to eq(setup.id)
  end
  it "has a name" do
    expect(subject[:name]).to eq(setup.name)
  end
  context "belongs to a campus" do
    let(:campus) { setup.campus }
    subject(:serializer) { serialized_setup[:campus] }
    it_behaves_like "a basic campus profile" do
      let(:expected) { campus }
    end
  end
  it "has events" do
    expect(subject.key?(:events)).to be_truthy
  end
end
