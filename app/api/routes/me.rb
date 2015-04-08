module Api
  class Me < Grape::API
    desc "Information about the logged in user"
    get :me do
      Church::MinimalIndividualSerializer.new(Church::Individual.find(1))
    end
  end
end
