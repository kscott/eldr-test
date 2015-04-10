module Api
  module V1
    class CheckinBase < Grape::API
      version 'v1', using: :accept_version_header

      before do
        connect_to_church_database(organization_application, :read)
        Company::OrganizationApplication.current = organization_application
      end

      helpers do
        def current_setup
          @current_setup ||= ::Church::CheckinSetup.find(current_token.resource_owner_id) if current_token && current_token.resource_owner_id
        end
      end
    end
  end
end
