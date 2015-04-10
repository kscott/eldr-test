module Api
  module V1
    class Lists < Grape::API
      # doorkeeper_for :all

      helpers do
        def filter_range(range)
          if range && range[:start] && range[:end]
            {
              start: Time.parse(range[:start].tr("-", "")),
              end: Time.parse(range[:end].tr("-", ""))
            }
          else
            {
              start: Date.today - 92.weeks,
              end: Date.today
            }
          end
        end

        def filter_campuses(campuses)
          if campuses
            unless campuses.kind_of?(Array)
              campuses = [campuses]
            end

            campuses
          else
            []
          end
        end
      end

      namespace :lists do
        namespace :mobile_carriers do
          desc "Return available mobile carriers"
          get do
            mobile_carriers = Church::Lists::MobileCarrier.all
            CollectionSerializer.new(mobile_carriers, serializer_class: Church::MobileCarrierSerializer, total_records: mobile_carriers.size)
          end
        end
        namespace :leadership_roles do
          desc "Get leadership roles"
          get do
            roles = Company::LeadershipRole.active
            CollectionSerializer.new(roles, serializer_class: Company::LeadershipRoleSerializer, total_records: roles.size)
          end
        end
        namespace :accounts do
          desc "Get chart of accounts entries"
          params do
            optional :campus, type: Array(Integer)
            optional :range, type: Hash do
              requires :start
              requires :end
            end
          end
          get do
            campuses = filter_campuses(declared(params)[:campus])
            range = filter_range(declared(params)[:range])
            accounts = Church::Account.find_all_by_campus_and_range(campuses, range)
            CollectionSerializer.new(accounts, serializer_class: Church::AccountSerializer, total_records: accounts.size, campus: campuses)
          end
          desc "Get specialized account listing for giving dashboard"
          params do
            requires :campus, type: Array[Integer]
          end
          get :dashboard do
            accounts = Church::Account.for_giving_metric(declared_params[:campus])
            CollectionSerializer.new(accounts, serializer_class: Church::AccountSerializer, total_records: accounts.size)
          end
        end
        namespace :attendance_groupings do
          desc "Get attendance grouping entries"
          params do
            optional :campus, type: Array(Integer)
          end
          get do
            groupings = Church::AttendanceGrouping.unscoped.order(:order_by)
            CollectionSerializer.new(groupings, serializer_class: Church::AttendanceGroupingSerializer, total_records: groupings.size, campus: declared_params[:campus])
          end
        end
      end
    end
  end
end
