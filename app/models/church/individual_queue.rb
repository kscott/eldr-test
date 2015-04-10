module Church
  class IndividualQueue < ::Church::Base
    serialize :date_due, ::CustomDateSerializer
    serialize :date_completed, ::CustomDateTimeSerializer
    self.table_name = 'individual_steps'
    self.primary_keys = :step_id, :individual_id
    belongs_to :queue
    belongs_to :individual

    before_save :set_record_dates, on: :create

    def set_record_dates
      self.date_due = "" unless self.date_due
      self.date_completed = "" unless self.date_completed
    end

    enum status_id: [:waiting, :in_process, :done, :not_started]
    alias_attribute :status, :status_id

    def active?
      ! done?
    end

    def manager
      @manager ||= Church::Individual.find(manager_id) if manager_id
    end

    def manager=(individual)
      @manager = individual
      manager_id = individual.id
    end
  end
end
