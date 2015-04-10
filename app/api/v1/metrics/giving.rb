module Api
  module V1
    module Metrics
      class Giving < ::Grape::API

        namespace :giving do
          desc "Metrics for the Giving category"
          params do
            requires :campus, type: Array[Integer]
            optional :grouping, type: Array[Symbol], default: [:weekly]
            optional :filters, type: Hash do
              optional :coa, type: Array[Integer]
            end
          end
          get do
          end
        end
      end
    end
  end
end
