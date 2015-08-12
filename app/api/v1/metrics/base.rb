module Api
  module V1
    module Metrics
      class Base < ::Grape::API
        # format :json

        # doorkeeper_for :all

        namespace :metrics do
          desc "Returns metrics and other information for the requested leadership role"
          params do
            requires :role, type: Symbol, values: [:executive_pastor]
            requires :campus, type: Array[Integer]
          end
          get do
            if current_individual.has_leadership_role?(declared_params[:role], declared_params[:campus])
              categories = Church::MetricCategory.for_role(declared_params[:role])
              CollectionSerializer.new(categories, serializer_class: Church::MetricCategorySerializer, total_records: categories.size)
            else
              error!({error: "No permission for role"}, 403)
            end
          end

          mount Metrics::Giving

        end
      end
    end
  end
end
