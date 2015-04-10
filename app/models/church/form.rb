module Church
  class Form < ::Church::Base
    self.table_name = "form_rev"
    has_many :responses, class_name: "FormResponse"
    has_many :questions
    has_one :profile
    belongs_to :campus

    def self.published
      where(published: true)
    end

    def self.active
      where("date_end = '0000-00-00' OR date_end >= ?", Time.zone.now.beginning_of_day).where("date_start <= ?", Time.zone.now.beginning_of_day)
    end

    def disabled?
      return true if automated_events_full?
      if questions.size > 0
        return true if disabled_required_question?
        return true if questions.size == disabled_questions.size
      else
        if profile
          return true if profile.fields.size == 0
        else
          return true
        end
      end
      if payment_option == "card_only"
        return true unless campus.merchant.allow_credit_card?
      end

      false
    end

    def automations
      @automations ||= Church::Automation.event_automations.where(choice_id: 0, question_id: 0, form_id: id)
    end

    def automated_events_full?
      @full ||= automations.inject(false) {|is_full, automation| is_full || automation.event.full? }
      @full
    end

    def disabled_questions
      @disabled ||= questions.select {|question| question.disabled? }
      @disabled
    end

    def disabled_required_question?
      disabled_questions.select(&:required?).size > 0
    end
  end
end
