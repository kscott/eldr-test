describe Church::CheckinLabelEventSerializer do
  before(:all) do
    @event = Church::Event.find(90)
    @entity = Church::Event::Occurrence.new(@event.id, @event.name, @event.datetime_start)
    @serializer = described_class.new(@entity).to_hash
  end

  %i(time room_name group_name event_id).each do |key|
    it "#{key} is present" do
      expect(@serializer.key?(key)).to be_truthy
    end
    it "#{key} contains the correct value" do
      expect(@serializer[key]).to eq(@entity.send(key))
    end
  end

  context "event display time" do
    it "matches the event's time" do
      expect(@serializer[:time]).to eq(@event.datetime_start.strftime("%-I:%M%p").sub(/(a|p)m/i, "\\1").downcase)
    end
  end
end
