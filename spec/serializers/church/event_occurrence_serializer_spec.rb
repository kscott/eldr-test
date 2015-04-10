describe Church::EventOccurrenceSerializer do
  let(:occurrence) { Church::Event::Occurrence.new(90, "Test Event Name", Time.now, "Friday") }
  subject(:serializer) { described_class.new(occurrence).to_hash }

  %i(occurrence name day_of_week time).each do |key|
    it "#{key} is present" do
      expect(subject[key]).to be_truthy
    end
    it "#{key} has the correct value" do
      expect(subject[key]).to eq(occurrence.send(key))
    end
  end
end
