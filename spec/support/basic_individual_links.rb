shared_examples_for "an individual with basic links" do
  context "links" do
    it "has a profile" do
      expect(serializer[:_links][:profile][:url]).to eq("/individuals/#{expected.id}")
    end
    it "has an edit link" do
      expect(serializer[:_links][:edit][:url]).to eq("/individuals/#{expected.id}")
    end
  end
end
