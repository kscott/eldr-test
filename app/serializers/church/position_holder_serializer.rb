module Church
  class PositionHolderSerializer < ::Church::BaseSerializer
    schema do
      type "position_holder"
      map_properties :status
      property :message, item.comment
      basic_individual_profile item.individual
    end
  end
end
