describe Church::SpecialDaySerializer do
  subject(:serializer) {described_class.new(special_day).to_hash}

  context "anniversary" do
    let(:special_day) do {
      name: "Joel and Breanne Rush",
      type: "anniversary",
      date: Date.parse("Sat, 16 Aug 2014"),
      primary_id: 54,
      secondary_id: 55
    }
    end

    it "has a title" do
      expect(serializer[:title]).to eq(special_day[:name])
    end

    it "has a date" do
      expect(serializer[:date]).to eq(special_day[:date])
    end

    it "has a type" do
      expect(serializer[:type]).to eq(special_day[:type])
    end

    it "has a primary link" do
      expect(serializer[:primary_link]).to_not be_nil
    end

    it "has a secondary link" do
      expect(serializer[:secondary_link]).to_not be_nil
    end
  end

  context "birthday" do
    let(:special_day) do {
      name: "Breanne Rush",
      type: "birthday",
      date: Date.parse("Sat, 28 Jun 2014"),
      primary_id: 55,
      secondary_id: nil
    }
    end

    it "has a title" do
      expect(serializer[:title]).to eq(special_day[:name])
    end

    it "has a date" do
      expect(serializer[:date]).to eq(special_day[:date])
    end

    it "has a type" do
      expect(serializer[:type]).to eq(special_day[:type])
    end

    it "has a primary link" do
      expect(serializer[:primary_link]).to_not be_nil
    end

    it "does not have a secondary link" do
      expect(serializer.key? :secondary_link).to be_falsey
    end
  end
end
