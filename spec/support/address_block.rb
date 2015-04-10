shared_examples_for "an address block" do
  it "with a street" do
    expect(subject[:street]).to eq(expected_address[:street])
  end

  it "with a city" do
    expect(subject[:city]).to eq(expected_address[:city])
  end

  it "with a state" do
    expect(subject[:state]).to eq(expected_address[:state])
  end

  it "with a zip" do
    expect(subject[:zip]).to eq(expected_address[:postal_code])
  end

  it "with a postal_code" do
    expect(subject[:postal_code]).to eq(expected_address[:postal_code])
  end
end
