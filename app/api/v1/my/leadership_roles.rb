module Api
  module V1
    module My
      class LeadershipRoles < ::Grape::API
        desc "Returns the current individual's leadership roles"
        get :leadership_roles do
          roles = Company::IndividualLeadershipRole.for_individual(current_individual)
          CollectionSerializer.new(roles, serializer_class: Company::IndividualLeadershipRoleSerializer, total_records: roles.size)
        end
      end
    end
  end
end
