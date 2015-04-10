module Church
  class MetricCategory < ::Church::Base
    self.table_name = "metric_category"
    has_many :metric_metric_categories, -> {order :order}
    has_many :metrics, through: :metric_metric_categories
    scope :active, -> { where(active: 1) }

    def leadership_role
      @leadership_role ||= Company::LeadershipRole.find(leadership_role_id)
    end

    def self.for_role(identifier)
      role = Company::LeadershipRole.find_by(short_name: identifier)
      statement = active.where(leadership_role_id: role.id)

      if Company::OrganizationApplication.current.pref_transactions.downcase == 'off'
        statement = statement.where.not(name: "Giving")
      end

      statement
    end

    def active?
      active == "1"
    end
  end
end
