module Church
  class MetricSerializer < ::Church::BaseSerializer
    schema do
      type "metric"
      map_properties :id, :name, :url, :api_type
      property :active, item.active?
    end
  end
end
