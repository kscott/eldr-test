shared_examples_for "a basic queue profile" do
  it "has an id" do
    expect(serializer[:id]).to eq(queue.id)
  end
  it "has a name" do
    expect(serializer[:name]).to eq(queue.name)
  end

  context "links" do
    it "profile" do
      expect(serializer[:_links][:profile][:url]).to eq("/queues/#{queue.id}")
    end
  end
end
