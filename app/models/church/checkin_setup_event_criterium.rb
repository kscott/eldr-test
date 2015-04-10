module Church
  class CheckinSetupEventCriterium < ::Church::Base
    belongs_to :checkin_setup
    self.inheritance_column = :target_type

    ALLOWED_CLASSES = {
      attendance_grouping: "AttendanceGroupingCriterium",
      group_type: "GroupTypeCriterium",
      department: "DepartmentCriterium"
    }

    def self.find_sti_class(type_name)
      "Church::#{ALLOWED_CLASSES[type_name.to_sym]}".constantize
    rescue NameError, TypeError
      super
    end

    def self.sti_name
      key = ALLOWED_CLASSES.key(self.to_s.demodulize)
      if key.nil?
        super
      else
        key.to_s
      end
    end
  end
end
