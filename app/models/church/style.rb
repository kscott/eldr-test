module Church
  class Style < ::Church::Base
    self.table_name = "style"
    belongs_to :position
  end
end
