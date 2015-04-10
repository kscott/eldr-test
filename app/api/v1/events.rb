module Api
  module V1
    class Events < Grape::API
      # doorkeeper_for :all, scopes: [:logged_in]

      namespace :events do
        params do
          requires :id, type: Integer
        end
        route_param :id, type: Integer do
          before do
            @event = Church::Event.find(declared_params[:id])
          end

          namespace :attendance do
            desc "Return individuals who may be used for attendance for the event"
            get :candidates, scopes: [:logged_in, :public_attendance] do
              attending = @event.guests.includes(individual: [:campus, :mobile_carrier]).by_attending
              participants = @event.group.participants.includes(individual: [:campus, :mobile_carrier])
              all = (attending + participants).uniq {|a| a.individual}.sort_by {|item| [item.individual.last_name, item.individual.first_name]}
              if all.size > 100
                error!({error: "Too many individuals"}, 413)
              else
                CollectionSerializer.new(all, serializer_class: Church::AttendanceCandidateSerializer, total_records: all.count)
              end
            end

            desc "Returns a specific attendance summary."
            params do
              requires :yyyymmdd, type: String
            end
            route_param :yyyymmdd, type: String do
              get do
                begin
                  occurrence = Time.parse(declared_params[:yyyymmdd])
                  attendance = @event.attendance_for_occurrence(occurrence)

                  ::Church::AttendanceSerializer.new(attendance)
                rescue RuntimeError => error
                  error!({error: error.message}, 400)
                end
              end

              desc "Creates/Updates an attendance record for the given event and occurrence"
              params do
                optional :head_count, type: Integer
                optional :visitors, type: Integer
                mutually_exclusive :head_count, :visitors
                requires :send_to, type: Symbol, values: -> { AttendanceSendToOptionsPolicy.new(Company::OrganizationApplication.current).evaluate }
                requires :summary, type: Hash do
                  optional :topic, type: String, default: ""
                  optional :notes, type: String, default: ""
                  optional :prayer_requests, type: String, default: ""
                  optional :people_information, type: String, default: ""
                end
                optional :did_not_meet, type: Boolean, default: false
                optional :attendees, type: Array[Integer]
              end
              post do
                attributes = declared_params
                attributes[:visitors] = declared_params[:head_count] unless attributes[:visitors]
                attributes[:attendees] = attributes.fetch(:attendees) { [] }
                attributes[:yyyymmdd] = Time.parse(declared_params[:yyyymmdd])
                attributes[:summary][:topic] = attributes[:summary][:topic][0...50]

                writable do
                  begin
                    content_type "application/json"
                    header 'Link', "events/#{@event.id}/attendance/#{attributes[:yyyymmdd].strftime("%Y%m%d")}"

                    if @event.save_attendance(attributes) == :create
                      status 201
                    else
                      status 200
                    end
                    attendance = @event.attendance_for_occurrence(attributes[:yyyymmdd])
                    JSON.parse(::Church::AttendanceSerializer.new(attendance).to_json)
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
