module Api
  class Base < Grape::API
    default_format :json

    before do
      config = {
        :adapter  => "mysql2",
        :host     => "localhost",
        :port => 33306,
        :username => "root",
        :password => "kds007",
        :database => "api_integration"
      }
      ActiveRecord::Base.connection.disconnect! if ActiveRecord::Base.connected?
      ActiveRecord::Base.establish_connection(config)
    end

    mount Api::Status
    mount Api::Me

  end
end
