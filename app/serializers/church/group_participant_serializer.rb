module Church
  class GroupParticipantSerializer < ::Church::BaseSerializer
    schema do
      type "participant"
      basic_individual_profile individual
      basic_family_profile individual
      basic_individual_links individual
      map_properties :group_id, :status
    end

    protected

    def individual
      item.individual
    end
  end
end
