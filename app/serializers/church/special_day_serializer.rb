module Church
  class SpecialDaySerializer < ::Church::BaseSerializer
    schema do
      type "special_day"
      properties do |p|
        p.title item[:name]
        p.date item[:date]
        p.type item[:type]
      end
      property :primary_images, images(item[:primary_id])
      property :secondary_images, images(item[:secondary_id]) if item[:secondary_id]

      link :primary_profile, href: individual_path(item[:primary_id]), authorized: IndividualPolicy.new(current_individual, Church::Individual.find(item[:primary_id])).show?
      if item[:secondary_id]
        link :secondary_profile, href: individual_path(item[:secondary_id]), authorized: IndividualPolicy.new(current_individual, Church::Individual.find(item[:secondary_id])).show?
      end
    end

    protected

    def images(id)
      Church::Individual.find(id).all_images
    end
  end
end
