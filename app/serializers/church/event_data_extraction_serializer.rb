module Church
  class EventDataExtractionSerializer < ::Church::BaseSerializer
    schema do
      type "event_data"
      properties do |p|
        p.id data_entity.id
        p.name data_entity.name
      end
      entity :group, data_entity.group, Church::MinimalGroupSerializer
      entity :campus, data_entity.group.campus, Church::CampusSerializer
    end

    def data_entity
      @entity ||= Church::Event.find(item.entity["id"])
    end
  end
end
