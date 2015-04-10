module Api
  module V1
    class Individuals < Grape::API
      # doorkeeper_for :all, scopes: [:logged_in]

      helpers do
          def extract_individual_profile_fields(params)
            profile_fields = {}
            params.each do |key, value|
              profile_fields[key_to_column(key)] = value
            end
            {
              # first_name: params[:first_name],
              # last_name: params[:last_name],
              email_primary: params[:email],
              phone_mobile: params[:mobile_phone],
              phone_mobile_sms_carrier_id: params[:mobile_carrier_id],
              phone_contact: params[:contact_phone],
              mailing_street: params[:street_address],
              mailing_city: params[:city],
              mailing_state: params[:state],
              mailing_zip: params[:zip],
              birthday: params[:birthday],
              anniversary: params[:anniversary]
            }
            profile_fields
          end
          def key_to_column(key)
            case key.to_sym
            when :email
              :email_primary
            when :mobile_phone
              :phone_mobile
            when :mobile_carrier_id
              :phone_mobile_sms_carrier_id
            when :contact_phone
              :phone_contact
            when :street_address
              :mailing_street
            when :city
              :mailing_city
            when :state
              :mailing_state
            when :zip
              :mailing_zip
            else
              key.to_sym
            end
          end
      end

      namespace :individuals do
        params do
          requires :id, type: Integer, desc: "Individual being requested"
        end
        route_param :id, type: Integer do
          before do
            @individual = Church::Individual.find(declared_params[:id])
            raise "Individual not found for id [#{declared_params[:id]}]" unless @individual
          end
          desc "Return individual information"
          get do
            Church::IndividualSerializer.new(@individual)
          end

          desc "Update individual information"
          params do
            # requires :first_name, type: String
            # requires :last_name, type: String
            optional :email, type: String, documentation: { example: "me@example.com" }
            optional :contact_phone, type: String
            optional :mobile_phone, type: String
            optional :mobile_carrier_id, type: Integer
            optional :street_address, type: String
            optional :city, type: String
            optional :state, type: String
            optional :zip, type: String
            optional :birthday, type: Date
            optional :anniversary, type: Date
          end
          put do
            writable do
              begin
                raise "No values provided for update" unless declared_params.count > 1
                # do something to update the individual
                @individual.update_profile(extract_individual_profile_fields(declared_params))
                content_type "application/json"
                header 'Link', "/individuals/#{@individual.id}"
                status 200
              rescue RuntimeError => error
                error!({error: error.message}, 400)
              end
            end
          end

          desc "Set the individual's mobile number"
          params do
            requires :carrier_id, type: Integer
            requires :number, type: String
          end
          put :mobile do

          end

          namespace :notes do
            desc "Returns notes for an individual"
            get do
              notes = NotePolicy::Scope.new(current_individual, Church::Note, individual: @individual, organization: organization_application).resolve

              # Build links to determine what sharing level of note can be created
              actions = {}
              Church::Note.sharing_levels.each do |level, value|
                actions["create_#{level.to_sym}"] = {
                  href: individual_notes_path(@individual, level),
                  authorized: NotePolicy.new(current_individual, Church::Note, individual: @individual, sharing_level: level.to_sym).create?
                }
              end

              CollectionSerializer.new(notes, serializer_class: Church::NoteSerializer, total_records: notes.size, actions: actions)
            end
            params do
              requires :note_id, type: Integer, desc: "Note ID"
            end
            route_param :note_id do
              before do
                @note = Church::Note.find(declared_params[:note_id])
                raise "Note not found for id [#{declared_params[:note_id]}]" unless @note
              end
              desc "Get a single note for an individual"
              get do
                Church::NoteSerializer.new @note
              end

              # desc "Update a note for the individual"
              # params do
              #   requires :content, type: String
              # end
              # post do
              #   begin
              #     @note.note = declared_params[:content]
              #     @note.save!

              #     content_type "application/json"
              #     header 'Link', individual_note_path(@individual, @note)
              #     status 200
              #   rescue Exception => e
              #     error!({error: e.message}, 400)
              #   end
              # end

              desc "Delete a note for the individual"
              delete do
                if NotePolicy.new(current_individual, @note).destroy?
                  writable do
                    serializer = Church::NoteSerializer.new @note
                    @note.destroy!

                    content_type "application/json"
                    status 200
                    serializer.to_json
                  end
                else
                  content_type "application/json"
                  status 403
                end
              end
            end

            params do
              requires :sharing_level, type: Symbol, values: Church::Note.sharing_levels.keys.map(&:to_sym), desc: "Note visibility"
            end
            route_param :sharing_level do
              desc "Creates a note for the individual"
              params do
                requires :content, type: String
                optional :date, type: Time
              end

              post do
                attributes = declared_params
                attributes[:date] = attributes[:date] ? Time.parse(attributes[:date].strftime("%Y-%m-%d")) : Time.now.strftime("%Y-%m-%d")

                writable do
                  begin
                    note = @individual.create_note(attributes)
                    serializer = Church::NoteSerializer.new note

                    content_type "application/json"
                    header 'Link', "/individuals/#{@individual.id}/notes"
                    status 201

                    serializer.to_json
                  rescue RuntimeError => error
                    error!({error: error.message}, 400)
                  end
                end
              end
            end
          end

          desc "Will set the individual's photo"
          params do
            requires :photo
          end
          post :photo do
            writable do
              begin
                file = declared_params[:photo].fetch("tempfile") { raise "Must provide a file" }
                content_type "application/json"
                status 200
                @individual.save_photo(file)
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
