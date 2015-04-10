module Api
  module V1
    module Public
      class Base < ::Grape::API
        format :json

        # doorkeeper_for :all

        namespace :public do
          mount Public::Attendance
          mount Public::Event
          mount Public::Need
          mount Public::Position
          mount Public::Assignments

          mount Public::DataExtraction
        end
      end
    end
  end
end
