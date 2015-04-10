module Church
  class Metric < ::Church::Base
    self.table_name = "metric"
    scope :active, -> { where(active: 1) }
    has_many :metric_metric_categories, -> {order :order}
    has_many :categories, through: :metric_metric_categories, source: :metric_category

    def active?
      active == "1"
    end
  end
end
