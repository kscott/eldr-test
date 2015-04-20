describe Church::IndividualSerializer do
  let(:individual) do
    Church::Individual.find(105)
  end

  subject (:serializer) { described_class.new(individual).to_hash }

  %i(id name first_name last_name email phone mobile_phone contact_phone birthday anniversary).each do |key|
    it "has a key named #{key}" do
      expect(serializer.key?(key)).to be_truthy
    end
    it "has the correct value for #{key}" do
      expect(serializer[key]).to eq(individual.send(key))
    end
  end
  it "has a spouse" do
    expect(serializer[:spouse][:name]).to eq(individual.spouse.name)
  end
  context "has an address" do
    subject(:serializer) { described_class.new(individual, current_individual: Church::Individual.current).to_hash[:address] }
    it "has a street" do
      expect(serializer[:street]).to eq(individual.mailing_address[:street])
    end

    it "has a city" do
      expect(serializer[:city]).to eq(individual.mailing_address[:city])
    end

    it "has a state" do
      expect(serializer[:state]).to eq(individual.mailing_address[:state])
    end

    it "has a zip" do
      expect(serializer[:zip]).to eq(individual.mailing_address[:zip])
    end
  end
  it "has a campus" do
    expect(serializer[:campus]).not_to be_nil
    expect(serializer[:campus][:name]).to eq(individual.campus.name)
  end
  context "has images" do
    %i(thumbnail small medium large extra_large).each do |size|
      it "uses the new image for #{size} size when it exists" do
        allow(individual).to receive(:image_exists?).and_return(true)
        expect(serializer[:image][size]).to match(/https?:\/\/ccbchurch.s3.amazonaws.com\/.*\/individual\/#{individual.id}.*/)
      end

      unless size == :thumbnail
        it "returns empty string for #{size} size when new images do not exist" do
          allow(individual).to receive(:image_exists?).and_return(false)
          expect(serializer[:image][size]).to be_empty
        end
      end
    end
  end

  context "links" do
    context "has a profile" do
      it "has content" do
        expect(serializer[:_links][:profile]).not_to be_nil
      end
      it "contains a url" do
        expect(serializer[:_links][:profile][:url]).to eq("/individuals/#{individual.id}")
      end
      context "when authorized" do
        it "will be allowed" do
          allow(individual).to receive(:led_by?).and_return(true)
          expect(serializer[:_links][:profile][:authorized]).to be_truthy
        end
      end
      context "when not authorized" do
        it "will not be allowed" do
          allow(individual).to receive(:led_by?).and_return(false)
          expect(serializer[:_links][:profile][:authorized]).to be_falsey
        end
      end
    end
    context "has an edit link" do
      it "has content" do
        expect(serializer[:_links][:edit]).not_to be_nil
      end
      it "has a url" do
        expect(serializer[:_links][:edit][:url]).to eq("/individuals/#{individual.id}")
      end
      context "when authorized" do
        it "will be allowed" do
          allow(individual).to receive(:led_by?).and_return(true)
          expect(serializer[:_links][:profile][:authorized]).to be_truthy
        end
      end
      context "when not authorized" do
        it "will not be allowed" do
          allow(individual).to receive(:led_by?).and_return(false)
          expect(serializer[:_links][:profile][:authorized]).to be_falsey
        end
      end
    end
  end
end
