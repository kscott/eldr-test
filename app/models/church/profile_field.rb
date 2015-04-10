module Church
  class ProfileField < ::Church::Base
    self.table_name = "form_profile_fields_rev"
    belongs_to :profile, foreign_key: :form_profile_id
  end
end
