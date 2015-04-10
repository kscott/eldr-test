module Api
  module V1
    module Search
      class Base < ::Grape::API
        format :json

        # doorkeeper_for :all

        namespace :search do
        end
      end
    end
  end
end
