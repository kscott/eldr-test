module Church
  class AttendanceGroupingSerializer < ::Church::BaseSerializer
    # include ::ActionView::Helpers::NumberHelper
    schema do
      map_properties :id, :name
      property :level, 0
      property :value, number_with_delimiter(item.attendance_for_range(engagement_week.week_start, engagement_week.week_end, context[:campus]), precision: 0)
    end
  end
end
