shared_examples_for "a basic campus profile" do
  it "has an id" do
    expect(subject[:id]).to eq(expected.id)
  end
  it "has a name" do
    expect(subject[:name]).to eq(expected.name)
  end
end
