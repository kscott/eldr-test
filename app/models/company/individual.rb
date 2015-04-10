module Company
  class Individual < ::Company::Base
    self.table_name = "individual"

    def church_individual
      begin
        @church_individual ||= Church::Individual.find(app_individual_id) unless app_individual_id == 0
      rescue
        nil
      end
    end

    def name
      church_individual ? church_individual.name : "#{name_first} #{name_last}"
    end

    def self.demo_authenticate(username, password)
      individual = where("demo_exp_date >= :demo_date", demo_date: Date.today).find_by(demo_login: username, demo_password: password)

      if individual
        individual
      else
        false
      end
    end

    def method_missing(method_name, *args, &block)
      church_individual.send(method_name, *args, &block) if church_individual
    end
  end
end
