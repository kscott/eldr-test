module Church
  class GroupType < ::Church::Base
    self.table_name = "group_type"
    has_many :groups, foreign_key: :type_id
  end
end
