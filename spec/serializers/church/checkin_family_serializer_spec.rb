describe Church::CheckinFamilySerializer do
  before(:all) do
    @entity = CheckinFamily.new(Church::Family.first)
    @serializer = described_class.new(@entity).to_hash
  end

  %i(family_name primary_contact spouse children others).each do |key|
    it "#{key} is present" do
      expect(@serializer.key?(key)).to be_truthy
    end
    unless %i(primary_contact spouse).include?(key)
      it "#{key} has the correct value" do
        expect(@serializer[key]).to eq(@entity.send(key))
      end
    end
  end

  context "primary contact and spouse" do
    %i(primary_contact spouse).each do |key|
      it "#{key} is the correct individual" do
        expect(@serializer[key][:id]).to eq(@entity.send(key).id)
      end
      it "#{key} is in the correct family" do
        expect(@serializer[key][:family_id]).to eq(@entity.id)
      end
    end
  end
end
