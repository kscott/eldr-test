module Api
  module V1
    module Checkin
      class Search < ::Grape::API
        # doorkeeper_for :all, scopes: %w(checkin)

        namespace :search do
          desc "Search using single family result rules"
          params do
            requires :value, type: String
            optional :name, type: String
          end
          post :single_family do
            value = declared_params[:value]
            value.gsub!(/[^[:alnum:]]/, "")
            name = declared_params[:name].strip if declared_params[:name]

            families = Church::Family.single_family_search(value, name)

            content_type "application/json"
            if families.size == 0
              status 404
            elsif families.size > 1
              status 403
              "Multiple families match the provided criteria"
            else
              family = ::CheckinFamily.new(Church::Family.find(families.first.id))
              family.add_events(current_setup.events_for)
              Church::CheckinFamilySerializer.new(family)
            end
          end
        end
      end
    end
  end
end
