module Api
  module V1
    module Public
      class Attendance < ::Grape::API
        # doorkeeper_for :all, scopes: %w(public_attendance)
        before do
          @auth_data = PublicAuthRequestData.from_string(declared_params[:data])
          unless @auth_data.context == "attendance"
            error!({error: "Invalid request type"}, 400)
          end

          @event = Church::Event.find(@auth_data.entity["id"])
        end

        desc "Returns a specific attendance summary."
        params do
          requires :data, type: String
        end
        get :attendance do
          begin
            occurrence = Time.parse(@auth_data.entity["occurrence"])
            attendance = @event.attendance_for_occurrence(occurrence)

            ::Church::AttendanceSerializer.new(attendance)
          rescue RuntimeError => error
            error!({error: error.message}, 400)
          end
        end

        desc "Creates an attendance record for the given event and occurrence"
        params do
          requires :data, type: String
          optional :visitors, type: Integer, default: 0
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
        post :attendance do
          attributes = declared_params
          attributes[:attendees] = attributes.fetch(:attendees) { [] }
          attributes[:yyyymmdd] = Time.parse(@auth_data.entity["occurrence"])
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
