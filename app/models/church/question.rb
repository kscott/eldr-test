module Church
  class Question < ::Church::Base
    self.table_name = "form_question_rev"
    belongs_to :form
    belongs_to :question_type, foreign_key: :form_question_type_id
    has_many :choices, foreign_key: :form_question_id

    def required?
      required == "1"
    end

    def disabled?
      if choices.size > 0
        return true if choices.size == disabled_choices.size
      else
        if type == :donation_amount
          return true
        end
      end
      return true if automated_events_full?

      false
    end

    def disabled_choices
      @disabled ||= choices.select {|choice| choice.disabled? }
      @disabled
    end

    def campus
      form.campus
    end

    def type
      question_type.type.to_sym
    end

    def automations
      @automations ||= Church::Automation.event_automations.where(choice_id: 0, question_id: id)
    end

    def automated_events_full?
      @full ||= automations.inject(false) {|is_full, automation| is_full || automation.event.full?(minimum_choice_quantity) }
      @full
    end

    def minimum_choice_quantity
      @quantity ||= choices.inject(1_000_000) {|min, choice| choice.minimum_responses.to_i < min ? choice.minimum_responses.to_i : min }
      @quantity
    end
  end
end
