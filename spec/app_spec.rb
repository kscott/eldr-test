describe Api::Base do
  let(:app) { Rack::Test::Session.new(described_class.new) }

  it "has methods for all http verbs" do
    %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
      expect(described_class.respond_to? verb.downcase.to_sym).to eq(true)
    end
  end

  %w(status /me /my /my/groups).each do |endpoint|
    it "returns 200 for the #{endpoint} endpoint" do
      response = app.get endpoint
      expect(response.status).to eq(200)
    end
  end
end
