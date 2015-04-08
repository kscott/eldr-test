module Church
  class MetricCategorySerializer < ::Church::BaseSerializer
    schema do
      type "metric_category"
      map_properties :id, :name
      property :active, item.active?
      entity :role, item.leadership_role, Company::LeadershipRoleSerializer
      entities :metrics, item.metrics.active, Church::MetricSerializer
    end
  end
end
