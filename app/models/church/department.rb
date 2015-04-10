module Church
  class Department < ::Church::Base
    self.table_name = "group_grouping"
    has_many :groups, foreign_key: :grouping_id
  end
end
