module Church
  class MinimalIndividualSerializer < ::Church::BaseSerializer
    schema do
      type "individual"
      map_properties :id, :name
      property :image, item.image(:thumbnail)
    end
  end
end
