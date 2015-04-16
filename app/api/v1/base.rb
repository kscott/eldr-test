module Api
  module V1
    class Base < Grape::API
      version 'v1', using: :accept_version_header

      helpers do
        def current_individual
          @current_individual ||= ::Church::Individual.find(1) # current_token.resource_owner_id) if current_token && current_token.resource_owner_id
        end
      end

      mount Me
      mount My::Base
      mount Campuses
      mount Groups
      mount Events
      mount Individuals
      mount Queues
      mount Lists
      mount Metrics::Base
      mount Public::Base
      # mount Search::Base
    end
  end
end
