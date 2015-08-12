module Api
  module V1
    module My
      class Base < ::Grape::API
        # format :json

        # doorkeeper_for :all, scopes: [:logged_in]

        # namespace :me do
        #   mount Me
        # end

        namespace :my do
          mount My::Groups
          mount My::LeadershipRoles
        end
      end
    end
  end
end
