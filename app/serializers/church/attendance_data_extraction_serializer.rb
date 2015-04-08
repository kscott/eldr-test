module Church
  class AttendanceDataExtractionSerializer < ::Church::BaseSerializer
    schema do
      type "attendance_data"
      property :occurrence, item.entity["occurrence"]
      entity :event, data_entity, Church::MinimalEventSerializer
      entity :group, data_entity.group, Church::MinimalGroupSerializer
      entity :campus, data_entity.group.campus, Church::CampusSerializer
    end

    def data_entity
      @entity ||= Church::Event.find(item.entity["id"])
    end
  end
end
