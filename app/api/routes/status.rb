module Api
  class Status < ::Grape::API
    desc "Test if the system is accepting requests"
    get :status do
      content_type "application/json"
      status 200
    end
  end
end
