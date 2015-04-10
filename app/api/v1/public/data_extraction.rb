module Api
  module V1
    module Public
      class DataExtraction < ::Grape::API
        helpers do
          def entity_serializer
            case @auth_data.context
            when "attendance"
              Church::AttendanceDataExtractionSerializer
            when "event"
              Church::EventDataExtractionSerializer
            when "need"
              Church::NeedDataExtractionSerializer
            when "position"
              Church::PositionDataExtractionSerializer
            when "assignment"
              Church::AssignmentDataExtractionSerializer
            else
              error!({error: "Unknown data context [#{@auth_data.context}]."}, 400)
            end
          end
        end

        params do
          requires :data, type: String, desc: "Public data object"
        end

        route_param :data do
          before do
            @auth_data = PublicAuthRequestData.from_string(declared_params[:data])
          end

          desc "Extract entity information"
          get do
            content_type "application/json"
            status 200
            entity_serializer.new(@auth_data)
          end
        end
      end
    end
  end
end
