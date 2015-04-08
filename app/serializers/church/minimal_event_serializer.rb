module Church
  class MinimalEventSerializer < ::Church::BaseSerializer
    schema do
      type "event"

      map_properties :id, :name, :room_ratio, :checkin_display_name
      entity :group, item.group, Church::MinimalGroupSerializer
    end
  end
end
