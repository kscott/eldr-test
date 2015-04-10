module Church
  class MetricMetricCategory < ::Church::Base
    self.table_name = "metric_metric_category"
    belongs_to :metric_category
    belongs_to :metric
  end
end
