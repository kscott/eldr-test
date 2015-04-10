module Company
  class OrganizationApplication < ::Company::Base
    self.table_name = "organization_application"
    has_and_belongs_to_many :organization_modules, join_table: "organization_modules", association_foreign_key: "module_id", foreign_key: "organization_id"

    scope :partial_subdomain, ->(subdomain) {
      subdomain = "%#{subdomain.gsub!(/%/, '')}%"
      where("private_ccbchurch_url_prefix LIKE :subdomain", subdomain: subdomain).order(:private_ccbchurch_url_prefix)
    }
    scope :partial_name, ->(name) {
      name = "%#{name.gsub!(/%/, '')}%"
      where("name LIKE :name", name: name).order(:name)
    }

    alias_attribute :subdomain, :private_ccbchurch_url_prefix

    def color
      "##{color_primary}"
    end

    def has_module?(name)
      ! organization_modules.find_by(name: name.to_s).nil?
    end

    def self.current
      Thread.current[:organization]
    end

    def self.current=(organization)
      Thread.current[:organization] = organization
    end

    def self.find_by_subdomain(subdomain)
      self.find_by_private_ccbchurch_url_prefix(subdomain)
    end

    def subdomain
      private_ccbchurch_url_prefix
    end

    def base_url
      "https://#{subdomain}.ccbchurch.com"
    end

    def engagement_week_for(date = Time.now)
      Church::EngagementWeek.where("engagement_week_type_id = :engagement_week AND DATE(:date) BETWEEN date_week_start AND date_week_end", engagement_week: pref_engagement_week, date: date).first
    end

    def master_administrator
      @ma ||= Company::Individual.where(contact_ma: "1", organization_id: self.id).first.church_individual
    end
  end
end
