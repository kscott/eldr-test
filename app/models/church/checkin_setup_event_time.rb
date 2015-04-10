module Church
  class CheckinSetupEventTime < ::Church::Base
    belongs_to :checkin_setup

    def to_s
      Time.parse(start_time).strftime("%H:%M %p")
    end
  end
end
