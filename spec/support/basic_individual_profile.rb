shared_examples_for "a basic individual profile" do
  it "has an id" do
    expect(subject[:id]).to eq(expected.id)
  end
  it "has a name" do
    expect(subject[:name]).to eq(expected.name)
    expect(subject[:first_name]).to eq(expected.name_first)
    expect(subject[:last_name]).to eq(expected.name_last)
  end
  it "has an email" do
    expect(subject[:email]).to eq(expected.email)
  end
  it "has a phone" do
    expect(subject[:phone]).to eq(expected.phone)
  end
  it "has a mobile phone" do
    expect(subject[:mobile_phone]).to eq(expected.mobile_phone)
  end
  it "has a mobile carrier" do
    expect(subject.key?(:mobile_carrier)).to be_truthy
  end
  it "has a home phone" do
    expect(subject[:home_phone]).to eq(expected.home_phone)
  end
  it "has a contact phone" do
    expect(subject[:contact_phone]).to eq(expected.contact_phone)
  end
  it "has a birthday" do
    expect(subject[:birthday]).to eq(expected.birthday)
  end
  it "has a anniversary" do
    expect(subject[:anniversary]).to eq(expected.anniversary)
  end
  context "has an address" do
    it "with a street" do
      expect(subject[:address][:street]).to eq(expected.mailing_address[:street])
    end

    it "with a city" do
      expect(subject[:address][:city]).to eq(expected.mailing_address[:city])
    end

    it "with a state" do
      expect(subject[:address][:state]).to eq(expected.mailing_address[:state])
    end

    it "with a zip" do
      expect(subject[:address][:zip]).to eq(expected.mailing_address[:zip])
    end
  end
  it "has a campus" do
    expect(subject[:campus]).not_to be_nil
    expect(subject[:campus][:name]).to eq(expected.campus.name)
  end

  context "images" do
    %i(thumbnail small medium large extra_large).each do |size|
      it "uses the new image for #{size} size when it exists" do
        allow(expected).to receive(:image_exists?).and_return(true)
        expect(subject[:image][size]).to match(/https?:\/\/ccbchurch.s3.amazonaws.com\/.*\/individual\/#{expected.id}.*/)
      end

      unless size == :thumbnail
        it "returns a blank string for #{size} size when new images do not exist" do
          allow(expected).to receive(:image_exists?).and_return(false)
          expect(subject[:image][size]).to be_empty
        end
      end
    end
  end
end
