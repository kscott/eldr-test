module Church
  class AttendanceCandidateSerializer < ::Church::BaseSerializer
    schema do
      type "basic-individual"
      basic_individual_profile individual
    end

    def individual
      item.individual
    end
  end
end
