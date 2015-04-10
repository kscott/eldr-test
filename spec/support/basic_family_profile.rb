shared_examples_for "a basic family profile" do
  it "has a spouse" do
    expect(subject[:spouse][:name]).to eq(expected.spouse.name)
  end

  it "has children" do
    expect(subject[:children].size).to be > 0
  end
end
