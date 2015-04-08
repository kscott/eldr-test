module Church
  class BaseSerializer < ::BaseSerializer
    include ::Serializers::Individual
    include ::Serializers::Group
    include ::Serializers::Queue

    protected

    def images(entity)
      entity.all_images
    end

    def current_individual
      Church::Individual.current
    end

    def current_organization
      Company::OrganizationApplication.current
    end
  end
end
