module Church
  class NeedDataExtractionSerializer < ::Church::BaseSerializer
    schema do
      type "need_data"
      properties do |p|
        p.id data_entity.id
        p.name data_entity.name
      end
    end

    def data_entity
      @entity ||= Church::Need.find(item.entity["id"])
    end
  end
end
