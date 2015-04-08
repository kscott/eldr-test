module Company
  class IndividualLeadershipRoleSerializer < ::Company::BaseSerializer
    schema do
      type "individual_leadership_role"
      entity :individual, item.individual, Church::MinimalIndividualSerializer
      entity :campus, item.campus, Church::BasicCampusSerializer
      entity :role, item.leadership_role, Company::LeadershipRoleSerializer
    end
  end
end
