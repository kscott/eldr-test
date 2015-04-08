module Church
  class CheckinLabelSerializer < ::Church::BaseSerializer
    schema do
      type "checkin_label"
      map_properties :first_name, :last_name, :security_code, :checkin_id, :comment, :pager_number, :date, :barcode
      property :label_type, context[:setup].label_type
      entities :events, item.events || [], CheckinLabelEventSerializer, setup: context[:setup]
    end
  end
end
