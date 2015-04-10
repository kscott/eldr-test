module Api
  class Base < Grape::API
    default_format :json

    before do
      organization_application = ::Company::OrganizationApplication.find_by_subdomain("apiplayground")
      DatabaseManagement.connect_to_church_database(organization_application, :read)
      Company::OrganizationApplication.current = organization_application
      Church::Individual.current = Church::Individual.find(1) # current_individual
    end

    mount Api::V1::Base
    mount Api::Status

  end
end
