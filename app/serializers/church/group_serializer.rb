module Church
  class GroupSerializer < ::Church::BaseSerializer
    schema do
      type "group"
      basic_group_profile item
    end
  end
end
