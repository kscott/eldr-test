module Api
  module V1
    module My
      class Groups < ::Grape::API
        desc "Returns the current individual's groups"
        params do
          optional :status, type: Symbol, values: [:participant, :member, :leader], default: :participant
        end
        get :groups do
          groups = current_individual.groups_led if declared_params[:status] == :leader
          groups = current_individual.groups if declared_params[:status] == :member
          groups = current_individual.groups if declared_params[:status] == :participant

          CollectionSerializer.new(groups, current_individual: current_individual, organization_id: organization_application.id, serializer_class: Church::MyGroupSerializer, total_records: groups.size)
        end
      end
    end
  end
end
