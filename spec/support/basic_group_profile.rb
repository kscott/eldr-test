shared_examples_for "a basic group profile" do
  it "has an id" do
    expect(subject[:id]).to eq(expected.id)
  end
  it "has a name" do
    expect(subject[:name]).to eq(expected.name)
  end
  it "has a campus" do
    expect(subject[:campus]).not_to be_nil
    expect(subject[:campus][:name]).to eq(expected.campus.name)
  end

  context "images" do
    %i(thumbnail small medium large extra_large).each do |size|
      it "uses the new image for #{size} size when it exists" do
        allow(expected).to receive(:image_exists?).and_return(true)
        expect(subject[:image][size]).to match(/https?:\/\/ccbchurch.s3.amazonaws.com\/.*\/group\/#{expected.id}.*/)
      end

      unless size == :thumbnail
        it "returns a blank string for #{size} size when new images do not exist" do
          allow(expected).to receive(:image_exists?).and_return(false)
          expect(subject[:image][size]).to be_empty
        end
      end
    end
  end

  context "links" do
    it "profile" do
      expect(subject[:_links][:profile][:url]).to eq("/groups/#{expected.id}")
    end
    it "edit" do
      expect(subject[:_links][:edit][:url]).to eq("/groups/#{expected.id}")
    end
    context "save_photo" do
      it "contains the correct url" do
        expect(subject[:_links][:save_photo][:url]).to eq("/groups/#{expected.id}/photo")
      end
      context "when the current user is a group leader" do
        it "access is allowed" do
          allow(expected).to receive(:leader?).and_return(true)
          expect(subject[:_links][:save_photo][:authorized]).to be_truthy
        end
      end
      context "when the current user is not a group leader" do
        it "access is not allowed" do
          allow(expected).to receive(:leader?).and_return(false)
          expect(subject[:_links][:save_photo][:authorized]).to be_falsey
        end
      end
    end
  end
end
