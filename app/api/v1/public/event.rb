module Api
  module V1
    module Public
      class Event < ::Grape::API
        # doorkeeper_for :all, scopes: %w(public_event)
        namespace :event do
          before do
            @auth_data = PublicAuthRequestData.from_string(declared_params[:data])
            unless @auth_data.context == "event"
              error!({error: "Invalid request type"}, 400)
            end

            @event = Church::Event.find(@auth_data.entity["id"])
            @individual = current_individual
          end

          desc "Returns event and RSVP information for an individual"
          params do
            requires :data, type: String
          end
          get :invitation do
            begin
              guest = Church::EventGuest.find_by(event_id: @event.id, individual_id: @individual.id)
              if guest
                Church::EventRsvpSerializer.new(guest)
              else
                # if individual is not on the guest list, throw an error
                error!({error: "Invitation not found"}, 404)
              end
            rescue RuntimeError => error
              error!({error: error.message}, 400)
            end
          end

          desc "Returns list of individuals related to the event"
          params do
            requires :data, type: String
          end
          get :guest_list do
            begin
              guests = []
              unless @event.hide_guest_list?
                guests = @event.guest_list
              end
              CollectionSerializer.new(guests, serializer_class: Church::GuestSerializer, total_records: guests.size)
            rescue RuntimeError => error
              error!({error: error.message}, 400)
            end
          end

          desc "Sets the event RSVP status for an individual"
          params do
            requires :data, type: String
            optional :quantity, type: Integer, default: 1
            requires :status, type: Symbol, values: [:attending, :declined, :undecided]
            optional :message, type: String
          end
          post :rsvp do
            attributes = declared_params
            attributes[:individual] = @individual
            writable do
              begin
                result = @event.save_response(attributes)
                content_type "application/json"
                status (result == :create ? 201 : 200)
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
