module Church
  class GroupTypeCriterium < CheckinSetupEventCriterium
    def target
      @target ||= Church::GroupType.find(target_id)
    end

    def events
      Church::Event.for_group_type(target)
    end
  end
end
