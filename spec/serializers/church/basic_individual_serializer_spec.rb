describe Church::BasicIndividualSerializer do
  before(:all) do
    @individual = Church::Individual.find(38)
  end

  subject (:serializer) { described_class.new(@individual).to_hash }

  it_behaves_like "a basic individual profile" do
    let(:expected) { @individual }
  end
  it_behaves_like "a basic family profile" do
    let(:expected) { @individual }
  end
  it_behaves_like "an individual with basic links" do
    let(:expected) { @individual }
  end
end
