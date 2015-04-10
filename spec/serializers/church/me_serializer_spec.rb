describe Church::MeSerializer do
  it_behaves_like "a basic individual profile" do
    let (:expected) { Church::Individual.find(38) }
    subject {described_class.new(expected).to_hash}
  end
end
