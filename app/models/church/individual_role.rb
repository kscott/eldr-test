module Church
  class IndividualRole < ::Church::Base
    self.table_name = "individual_sections"
    belongs_to :role, foreign_key: 'section_id'
    belongs_to :individual
  end
end
