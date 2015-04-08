module Church
  class SummarySerializer < ::Church::BaseSerializer
    schema do
      type "summary"
      map_properties :topic, :notes, :prayer_requests, :people_information
    end
  end
end
