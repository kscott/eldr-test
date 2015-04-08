module Church
  class AssignmentDataExtractionSerializer < ::Church::BaseSerializer
    schema do
      type "assignment_data"
    end

    def data_entity
      @entity ||= nil
    end
  end
end
