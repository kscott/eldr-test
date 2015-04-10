module Church
  class AttendanceGroupingCriterium < CheckinSetupEventCriterium
    def target
      @target ||= Church::AttendanceGrouping.find(target_id)
    end

    def events
      target.events
    end
  end
end
