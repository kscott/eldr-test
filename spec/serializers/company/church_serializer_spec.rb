describe Company::ChurchSerializer do
  before(:all) do
    @organization = Company::OrganizationApplication.find_by(subdomain: ENV["INTEGRATION_TEST_SUBDOMAIN"])
  end

  subject (:serializer) {described_class.new(@organization).to_hash}

  it "does not provide an organization id" do
    expect(serializer.key?(:id)).to be_falsy
  end

  it "has a subdomain" do
    expect(serializer[:subdomain]).to eq(@organization.subdomain)
  end

  it "has a name" do
    expect(serializer[:name]).to eq(@organization.name)
  end

  it 'has a color' do
    expect(serializer[:color]).to eq("##{@organization.color_primary}")
  end

  it 'has login page text' do
    expect(serializer[:login_text]).to eq(@organization.login_page_text)
  end
end
