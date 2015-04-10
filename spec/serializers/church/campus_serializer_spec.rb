describe Church::CampusSerializer do
  before(:all) do
    @campus = Church::Campus.new(id: 1, name: "Campus 1")
  end

  subject (:serializer) {described_class.new(@campus).to_hash}

  it "has an id" do
    expect(serializer[:id]).to eq(@campus.id)
  end

  it "has a name" do
    expect(serializer[:name]).to eq(@campus.name)
  end
end
