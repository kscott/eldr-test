describe Church::AssignmentSerializer do
  let(:assignment) { Church::Individual.find(80).assignments.last }
  subject(:serializer) {described_class.new(assignment).to_hash}

  it "has an id" do
    expect(serializer[:id]).to eq(assignment.id)
  end

  it "has a status" do
    expect(serializer[:status]).to eq(assignment.status)
  end

  it "has a note" do
    expect(serializer[:note]).to eq(assignment.note)
  end

  it "has a date" do
    expect(serializer[:date]).to eq(assignment.date)
    expect(serializer[:date]).to match(/^\d{4}(-\d{2}){2}$/)
  end

  it "has times" do
    expect(serializer.key?(:times)).to be_truthy
  end

  context "assignment times" do
    subject { serializer[:times].first }

    it "have a name" do
      expect(subject[:name]).to eq(assignment.times.first.name)
    end

    it "have a display property" do
      expect(subject[:display]).to eq(assignment.times.first.display)
    end

    it "have a display_time" do
      expect(subject[:display_time]).to eq(assignment.times.first.display_time)
    end

    it "have a label" do
      expect(subject[:label]).to eq(assignment.times.first.label)
    end

    it "know if they are a service time" do
      expect(subject[:service_time]).to eq(assignment.times.first.service_time?)
    end
  end

  it_behaves_like "a basic individual profile" do
    subject { serializer[:individual] }
    let(:expected) {assignment.individual}
  end

  it_behaves_like "a basic position profile" do
    subject { serializer[:position] }
    let(:expected) {assignment.position}
  end
end
