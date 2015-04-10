shared_examples_for "a basic position profile" do
  it "has an id" do
    expect(subject[:id]).to eq(expected.id)
  end
  it "has a name" do
    expect(subject[:name]).to eq(expected.name)
  end
  it "has a group" do
    expect(subject.key?(:group)).to be_truthy
    expect(subject[:group][:name]).to eq(expected.group.name)
  end
end
