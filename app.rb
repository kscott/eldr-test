class App < Eldr::App
  get '/' do
    Rack::Response.new "Hello World", 200
  end
end

class API < Grape::API
  get :grape do
    content_type "application/json"
    {hello: "grape"}
  end

  get :other do
    content_type "application/json"
    { response: "hello other" }
  end

  get :status do
    content_type "application/json"
    status 200
  end
end

