describe Church::CheckinIndividualSerializer do
  before(:all) do
    @individual = CheckinFamilyMember.new(Church::Individual.last)
    @serializer = described_class.new(@individual).to_hash
  end


  %i(id first_name last_name name email phone mobile_phone home_phone contact_phone birthday anniversary image active limited tokens last_login address campus mobile_carrier events).each do |key|
    it "#{key} is present" do
      expect(@serializer.key?(key)).to be_truthy
    end
    unless %i(active limited campus image).include?(key)
      it "#{key} has correct value" do
        expect(@serializer[key]).to eq(@individual.send(key))
      end
    end
  end

  it "has the correct value for active" do
    expect(@serializer[:active]).to eq(@individual.active?)
  end
  it "has the correct value for limited" do
    expect(@serializer[:limited]).to eq(@individual.limited?)
  end
  it "has the correct value for campus" do
    expect(@serializer[:campus][:id]).to eq(@individual.campus.id)
  end
end
