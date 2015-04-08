module Church
  class AccountSerializer < ::Church::BaseSerializer
    # include ::ActionView::Helpers::NumberHelper
    schema do
      map_properties :id, :name
      property :level, item.depth
      property :value, number_to_currency(item.giving_for_range(engagement_week.week_start, engagement_week.week_end, context[:campus]), precision: 0)
    end
  end
end
