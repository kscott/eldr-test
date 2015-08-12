module Api
  module V1
    module Checkin
      class Base < ::Grape::API
        version 'v1', using: :accept_version_header
        # format :json
        # doorkeeper_for :all

        before do
          connect_to_church_database(organization_application, :read)
          Company::OrganizationApplication.current = organization_application
        end

        helpers do
          def current_setup
            @current_setup ||= ::Church::CheckinSetup.find(current_token.resource_owner_id) if current_token && current_token.resource_owner_id
          end
        end

        namespace :checkin do
          mount Checkin::General
          mount Checkin::Search
        end
      end
    end
  end
end
