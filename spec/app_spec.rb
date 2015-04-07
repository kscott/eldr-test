describe API do
  it "has methods for all http verbs" do
    %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
      expect(described_class.respond_to? verb.downcase.to_sym).to eq(true)
    end
  end

  it "returns 200 for the /status endpoint" do
    app = Rack::Test::Session.new described_class.new
    response = app.get "/status"
    expect(response.status).to eq(200)
  end
end
