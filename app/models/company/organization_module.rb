module Company
  class OrganizationModule < ::Company::Base
    self.table_name = "module"

    has_and_belongs_to_many :organization_modules, join_table: "organization_modules", association_foreign_key: "organization_id", foreign_key: "module_id"
  end
end
