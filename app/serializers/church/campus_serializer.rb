module Church
  class CampusSerializer < ::Church::BaseSerializer
    schema do
      type "campus"
      map_properties :id, :name, :locale, :timezone
    end
  end
end
