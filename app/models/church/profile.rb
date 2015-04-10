module Church
  class Profile < ::Church::Base
    self.table_name = "form_profile_rev"
    has_many :fields, class_name: "ProfileField", foreign_key: :form_profile_id
  end
end

