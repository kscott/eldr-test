module Church
  class MinimalGroupSerializer < ::Church::BaseSerializer
    schema do
      type "group"
      map_properties :id, :name
    end
  end
end
