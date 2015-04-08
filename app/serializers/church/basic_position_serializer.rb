module Church
  class BasicPositionSerializer < ::Church::BaseSerializer
    schema do
      type "position"

      map_properties :id, :name
      entity :group, item.group, Church::BasicGroupSerializer
      entities :spiritual_gifts, item.spiritual_gifts do |item, s|
        s.property :name, item.name
      end
      entities :styles, item.styles do |item, s|
        s.property :name, item.name
      end

    end
  end
end
