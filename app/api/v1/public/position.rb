module Api
  module V1
    module Public
      class Position < ::Grape::API
        # doorkeeper_for :all, scopes: %w(public_position)
        namespace :position do
          before do
            @auth_data = PublicAuthRequestData.from_string(declared_params[:data])
            unless @auth_data.context == "position"
              error!({error: "Invalid request type"}, 400)
            end

            @position = Church::Position.find(@auth_data.entity["id"])
            @individual = current_individual
          end

          desc "Get the status of an individual for a position"
          params do
            requires :data, type: String, desc: "Authentication information"
          end
          get :invitation do
            begin
              position_notice = Church::IndividualPosition.find_by(position: @position, individual: @individual)
              if position_notice
                Church::PositionNoticeSerializer.new(position_notice)
              else
                error!({error: "Invalid request"}, 400)
              end
            rescue RuntimeError => error
              error!({error: error.message}, 400)
            end
          end

          desc "Provide a response to a position"
          params do
            requires :data, type: String, desc: "Authentication information"
            requires :status, type: Symbol, values: [:accepted, :declined, :undecided], desc: "Status of the individual for the position"
            optional :message, type: String, desc: "Message to position leader"
          end
          post :response do
            writable do
              begin
                position_notice = Church::IndividualPosition.find_by(position: @position, individual: @individual)
                if position_notice
                  if @position.save_response(individual: @individual, status: declared_params[:status], message: declared_params[:message])
                    content_type "application/json"
                    status 200
                  else
                    error!({error: "Invalid request"}, 400)
                  end
                else
                  error!({error: "Invalid request"}, 400)
                end
              rescue RuntimeError => e
                error!({error: e.message}, 400)
              end
            end
          end
        end
      end
    end
  end
end
