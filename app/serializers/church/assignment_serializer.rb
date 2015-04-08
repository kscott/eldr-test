module Church
  class AssignmentSerializer < ::Church::BaseSerializer
    schema do
      type "assignment"
      map_properties :id, :status, :note, :date
      entity :individual, item.individual, Church::BasicIndividualSerializer
      entity :position, item.position, Church::BasicPositionSerializer
      entities :times, item.times do |item, s|
        s.map_properties :name, :display, :display_time, :label
        s.property :service_time, item.service_time?
      end
    end
  end
end
