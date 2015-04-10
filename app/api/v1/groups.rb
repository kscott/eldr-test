module Api
  module V1
    class Groups < Grape::API
      # doorkeeper_for :all, scopes: [:logged_in]

      helpers do
        def resolve_range_parameter(range, relative_to)
          ::Chronic.parse("#{range[:interval]} #{range[:interval_type].to_s} #{range[:direction].to_s}", now: relative_to)
        end

        def relative_to
          Time.parse(declared_params[:relative_to].tr("-", ""))
        end
      end

      namespace :groups do
        params do
          requires :id, type: Integer, desc: "Group being requested"
        end
        route_param :id, type: Integer do
          before do
            @group = Church::Group.find(declared_params[:id])
          end

          desc "Returns group information"
          get do
            ::Church::GroupSerializer.new(@group)
          end

          desc "Returns upcoming group meetings"
          params do
            optional :relative_to, type: String, default: ::Chronic.parse("now").strftime("%Y%m%d")
            optional :starting, type: Hash do
              optional :interval, type: Integer, default: 3
              optional :interval_type, type: Symbol, values: [:days, :weeks, :months], default: :months
              optional :direction, type: Symbol, values: [:future, :past], default: :past
            end
            optional :ending, type: Hash do
              optional :interval, type: Integer, default: 2
              optional :interval_type, type: Symbol, values: [:days, :weeks, :months], default: :weeks
              optional :direction, type: Symbol, values: [:future, :past], default: :future
            end
          end
          get :meetings do
            starting = resolve_range_parameter(declared_params[:starting], relative_to)
            ending = resolve_range_parameter(declared_params[:ending], relative_to)
            if (ending < starting)
              starting, ending = ending, starting
            end

            meetings = @group.meetings(starting, ending)
            CollectionSerializer.new(meetings, current_individual: current_individual, organization_id: organization_application.id, serializer_class: Church::MeetingSerializer, total_records: meetings.size)
          end

          desc "Returns the group's participants"
          params do
            optional :filter, type: String, desc: "Filter participants by this name"
          end
          get :participants do
            participants = @group.participants
            if params[:filter]
              filter = params[:filter].downcase
              participants = participants.find_all { |ind| ind.individual.first_name.downcase.start_with?(filter) || ind.individual.last_name.downcase.start_with?(filter) || ind.individual.name.downcase.include?(filter) }
            end
            CollectionSerializer.new(participants, current_individual: current_individual, organization_id: organization_application.id, serializer_class: Church::GroupParticipantSerializer, total_records: participants.size)
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
                @group.save_photo(file)
              rescue RuntimeError => error
                error!({error: error.message}, 400)
              end
            end
          end

          desc "Return birthdays and anniversaries for group participants"
          params do
            optional :relative_to, type: String, default: ::Chronic.parse("now").strftime("%Y%m%d")
            optional :starting, type: Hash do
              optional :interval, type: Integer, default: 2
              optional :interval_type, type: Symbol, values: [:days, :weeks, :months], default: :weeks
              optional :direction, type: Symbol, values: [:future, :past], default: :past
            end
            optional :ending, type: Hash do
              optional :interval, type: Integer, default: 12
              optional :interval_type, type: Symbol, values: [:days, :weeks, :months], default: :months
              optional :direction, type: Symbol, values: [:future, :past], default: :future
            end
          end
          get :special_days do
            starting = resolve_range_parameter(declared_params[:starting], relative_to)
            ending = resolve_range_parameter(declared_params[:ending], relative_to)

            if (ending < starting)
              starting, ending = ending, starting
            end
            days = @group.special_days starting, ending
            CollectionSerializer.new(days, current_individual: current_individual, organization_id: organization_application.id, serializer_class: Church::SpecialDaySerializer, total_records: days.size)
          end
        end
      end
    end
  end
end
