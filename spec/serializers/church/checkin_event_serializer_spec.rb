describe Church::CheckinEventSerializer do
  before(:all) do
    event = Church::Event.find(90)
    occurrence = Church::Event::Occurrence.new(event.id, event.name, Time.now.change({ hour: event.datetime_start.hour, min: event.datetime_start.min, sec: event.datetime_start.sec }))
    @entity = Church::Checkin::Event.new(occurrence, :attending)
    @serializer = described_class.new(@entity).to_hash
  end


  %i(name status id occurrence).each do |key|
    it "#{key} is present" do
      expect(@serializer.key?(key)).to be_truthy
    end
    unless key == :occurrence
      it "#{key} has the correct value" do
        expect(@serializer[key]).to eq(@entity.send(key))
      end
    else
      it "occurrence has the correct value" do
        expect(@serializer[key]).to eq(@entity.send(key).to_time)
      end
    end
  end
end
