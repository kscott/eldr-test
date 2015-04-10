module Api
  module V1
    module Public
      class Need < ::Grape::API
        # doorkeeper_for :all, scopes: %w(public_need)
        namespace :need do
          before do
            @auth_data = PublicAuthRequestData.from_string(declared_params[:data])
            unless @auth_data.context == "need"
              error!({error: "Invalid request type"}, 400)
            end

            @need = Church::Need.find(@auth_data.entity["id"])
            @individual = current_individual
          end

          desc "Get information about a need"
          params do
            requires :data, type: String, desc: "Authentication information"
          end
          get do
            Church::NeedSerializer.new(@need)
          end

          namespace :item do
            params do
              requires :id, type: Integer, desc: "The need item to be accepted or not"
            end

            route_param :id do
              desc "Allows an individual to accept a need item"
              params do
                requires :data, type: String
              end
              post do
                need_item = Church::NeedItem.find_by(need_id: @need.id, id: declared_params[:id])
                writable do
                  begin
                    status = @need.assign_item(need_item, @individual)
                    status_code = case status
                                  when :assigned
                                    200
                                  when :unchanged
                                    202
                                  when :unavailable
                                    410
                                  else
                                    400
                                  end

                    content_type "application/json"
                    status status_code
                  rescue RuntimeError => error
                    error!({error: error.message}, 400)
                  end
                end
              end

              desc "Allows an individual to remove themselves from a need item"
              params do
                requires :data, type: String
              end
              delete do
                need_item = Church::NeedItem.find(declared_params[:id])
                writable do
                  begin
                    status = @need.unassign_item(need_item, @individual)
                    status_code = case status
                                  when :removed
                                    200
                                  when :unavailable
                                    410
                                  end

                    content_type "application/json"
                    status status_code
                  rescue RuntimeError => error
                    error!({error: error.message}, 400)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
