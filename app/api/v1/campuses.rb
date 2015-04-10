module Api
  module V1
    class Campuses < Grape::API
      # doorkeeper_for :all

      namespace :campuses do
        desc "Listing of all campuses for the current organization"
        get do
          campuses = Church::Campus.all
          CollectionSerializer.new(campuses, serializer_class: Church::BasicCampusSerializer, total_records: campuses.size)
        end
      end
    end
  end
end
