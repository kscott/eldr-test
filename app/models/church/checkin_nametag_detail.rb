module Church
  class CheckinNametagDetail < ::Church::Base
    self.table_name = :checkin_nametag_detail
    belongs_to :checkin
  end
end
