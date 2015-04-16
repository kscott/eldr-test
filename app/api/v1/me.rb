module Api
  module V1
    class Me < Grape::API
      desc "Returns information about the logged-in individual"
      get :me do
        ::Church::MeSerializer.new(current_individual)
      end
    end
  end
end
