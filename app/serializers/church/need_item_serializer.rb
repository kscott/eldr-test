module Church
  class NeedItemSerializer < ::Church::BaseSerializer
    schema do
      type "need_item"

      map_properties :id, :name, :date
      entity :assigned_to, item.assigned_to, Church::BasicIndividualSerializer
    end
  end
end
