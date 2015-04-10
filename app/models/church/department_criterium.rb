module Church
  class DepartmentCriterium < CheckinSetupEventCriterium
    def target
      @target ||= Church::Department.find(target_id)
    end

    def events
      Church::Event.for_department(target)
    end
  end
end
