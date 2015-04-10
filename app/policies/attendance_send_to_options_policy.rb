class AttendanceSendToOptionsPolicy
  attr_accessor :organization

  def initialize(organization)
    @organization = organization
  end

  def evaluate
    options = [:none, :participants]
    if organization && organization.has_module?(:mod_group_structure_on)
      options << :leaders
    end
    options
  end
end
