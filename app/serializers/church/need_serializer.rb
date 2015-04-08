module Church
  class NeedSerializer < ::Church::BaseSerializer
    schema do
      type "need"

      map_properties :id, :name, :description

      entity :group, item.group, Church::BasicGroupSerializer
      entity :coordinator, item.coordinator, Church::BasicIndividualSerializer
      entities :items, item.items, Church::NeedItemSerializer
    end
  end
end
