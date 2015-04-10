module Api
  module V1
    module Public
      class Assignments < ::Grape::API
        # doorkeeper_for :all, scopes: %w(public_assignments)
        namespace :assignments do
          before do
            @auth_data = PublicAuthRequestData.from_string(declared_params[:data])
            unless @auth_data.context == "assignment"
              error!({error: "Invalid request type"}, 400)
            end

            @individual = current_individual
          end

          desc "Get the individual's current schedule assignments"
          params do
            requires :data, type: String, desc: "Authentication information"
          end
          get do
            begin
              assignments = @individual.assignments
              CollectionSerializer.new(assignments, serializer_class: Church::AssignmentSerializer, total_records: assignments.count)
            rescue RuntimeError => error
              error!({error: error.message}, 400)
            end
          end

          params do
            requires :id, type: Integer, desc: "Respond to a scheduling assignment"
          end
          route_param :id do
            before do
              @assignment = Church::ScheduleDetailAssignment.find(declared_params[:id])
              unless @assignment
                error!({error: "Assignment cannot be found"}, 404)
              end

              unless @assignment.individual == @individual
                error!({error: "Invalid request"}, 400)
              end
            end

            desc "Respond to a scheduling assignment"
            params do
              requires :data, type: String, desc: "Authentication information"
              requires :status, type: Symbol, values: Church::ScheduleDetailAssignment::STATUS.keys, desc: "The status of the person scheduled"
              optional :note, default: "", type: String, desc: "Message to the scheduler"
            end
            post do
              begin
                attributes = declared_params.except(:id, :data)
                @assignment.update_response(attributes)
                content_type "application/json"
                status 200
              rescue Exception => e
                error!({error: e.message}, 400)
              end
            end
          end
        end
      end
    end
  end
end
