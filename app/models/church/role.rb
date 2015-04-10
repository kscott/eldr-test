module Church
  class Role < ::Church::Base
    self.table_name = "z_section"
    belongs_to :role
    belongs_to :individual
  end
end
