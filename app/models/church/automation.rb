module Church
  class Automation < ::Church::Base
    self.table_name = "form_automation_rev"
    belongs_to :event, foreign_key: :target_id
    belongs_to :form
    belongs_to :question
    belongs_to :choice
    belongs_to :option

    enum automation_type_id: { group_automation: 1, event_automation: 2, position_automation: 3, queue_automation: 4, email_automation: 5 }
    alias_attribute :automation_type, :automation_type_id

    def responses
      form.responses.includes(:answers).select {|r| r.satisfies?(self) }
    end

    def matched_responses
      form.responses.matched.select {|r| r.satisfies?(self) }
    end

    def unmatched_responses
      form.responses.unmatched.select {|r| r.satisfies?(self) }
    end

    def registration_count(responses)
      if event_automation?
        responses.inject(0) { |sum, response| sum + response.registration_count(self) }
      else
        0
      end
    end

    def matching_type
      if option_id > 0
        :option
      elsif choice_id > 0
        :choice
      elsif question_id > 0
        :question
      else
        :form
      end
    end

    def self.for_event(event)
      event_automations.joins(:event).merge(Church::Event.where(id: event.id))
    end

    def self.automated_forms
      joins(:form).merge(Church::Form.active.published.order("date_end = '0000-00-00' ASC", date_end: :asc, date_start: :desc, date_created: :desc))
    end

    def self.event_automations
      where(automation_type_id: Automation::automation_type_ids[:event_automation])
    end

    def self.for_event_id(event_id)
      event_automations.where(target_id: event_id)
    end

    def self.form_automations
      where(question_id: 0)
    end

    def self.question_automations
      where.not(question_id: 0).where(choice_id: 0)
    end

    def self.choice_automations
      where.not(question_id: 0).where.not(choice_id: 0).where(option_id: 0)
    end

    def self.option_automations
      where.not(question_id: 0).where.not(choice_id: 0).where.not(option_id: 0)
    end
  end
end
