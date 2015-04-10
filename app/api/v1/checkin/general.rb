module Api
  module V1
    module Checkin
      class General < ::Grape::API
        # doorkeeper_for :all, scopes: %w(checkin)

        desc "Currently authenticated checkin station"
        get :station do
          Church::CheckinSetupSerializer.new(current_setup) if current_setup
        end

        desc "Listing of checkin station setups"
        params do
          requires :campus_id, type: Integer
          optional :type, type: Symbol, values: [:all, :manned, :self], default: :all
        end
        get :setups, scopes: [] do
          campus = Church::Campus.find(declared_params[:campus_id])
          setups = campus.checkin_setups.by_type(declared_params[:type])
          CollectionSerializer.new(setups, serializer_class: Church::BasicCheckinSetupSerializer, total_records: setups.size)
        end

        desc "Check individuals into the current setup"
        params do
          requires :family, type: Array do
            requires :individual_id, type: Integer
            requires :event_id, type: Integer
            requires :status, type: Symbol, values: [:add, :delete]
          end
          optional :contacts, type: Array do
            requires :individual_id, type: Integer
            requires :name, type: String
            requires :number, type: String
            requires :carrier, type: Integer
          end
        end
        post do
          setup_events = current_setup.events_for
          family = []
          declared_params[:family].each do |record|
            occurrence = setup_events.find {|e| e.id == record[:event_id] }

            unless occurrence
              error!("Event provided is not recognized", 400)
            end

            member = ::CheckinFamilyMember.new(Church::Individual.find(record[:individual_id]))
            member.checkin_action = record[:status]
            member.events << occurrence
            family << member
          end

          policy = CheckinAttendancePolicy.new(family, current_setup)

          if policy.allow_checkin?
            labels = ::CheckinProcess.execute(policy, declared_params[:contacts])
            CollectionSerializer.new(labels, serializer_class: Church::CheckinLabelSerializer, total_records: labels.size, setup: current_setup)
          else
            content_type "application/json"
            status 412
            CollectionSerializer.new(policy.family, serializer_class: Church::CheckinFailureSerializer, total_records: policy.family.size)
          end

        end
      end
    end
  end
end
