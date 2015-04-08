module Church
  class PositionNoticeSerializer < ::Church::BaseSerializer
    schema do
      type "position_notice"
      map_properties :status
      property :message, item.comment
      entity :individual, item.individual, Church::BasicIndividualSerializer
      entity :position, item.position, Church::BasicPositionSerializer
    end
  end
end
