module Api
  class Me < Grape::API
    desc "Information about the logged in user"
    get :me do
      Church::Individual.find(1).attributes
    end
  end
end
