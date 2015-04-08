module Church
  class BasicGroupSerializer < ::Church::BaseSerializer
    schema do
      type "group"
      basic_group_profile item
    end
  end
end
