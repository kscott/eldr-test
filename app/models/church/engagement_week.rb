module Church
  class EngagementWeek < ::Church::Base
    self.table_name = "z_engagement_week"

    alias_attribute :week_start, :date_week_start
    alias_attribute :week_end, :date_week_end
  end
end
