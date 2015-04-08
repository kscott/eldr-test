module Company
  class LeadershipRoleSerializer < ::Company::BaseSerializer
    schema do
      type "leadership_role"
      map_properties :id, :title, :display_name, :identifier, :acronym, :link
    end
  end
end
