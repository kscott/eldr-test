module Church
  class Individual
    class ExtraInfo < ::Church::Base
      self.table_name = "individual_extra_info"
      belongs_to :individual
    end
  end
end
