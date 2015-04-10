module Church
  class Choice < ::Church::Base
    self.table_name = "form_question_choices_rev"
    belongs_to :question, foreign_key: :form_question_id
    belongs_to :account, foreign_key: :transaction_detail_type_id

    def disabled?
      return false if hidden?
      if requires_account?
        return true if account.nil?
        return true unless CampusAccount.active?(campus, account)
      end
      if total_available > 0
        return true if quantity_sold >= total_available
        return true if (quantity_sold + minimum_responses) > total_available
      end
      return true if automated_events_full?

      false
    end

    def hidden?
      hidden == "1"
    end

    def campus
      question.campus
    end

    def answers
      @answers ||= Answer.where(choice: self)
      @answers
    end

    def quantity_sold
      @quantity_sold ||= answers.inject(0) {|sum, answer| sum + answer.value.to_i }
      @quantity_sold
    end

    def requires_account?
      (question.type == :product && price > 0) || question.type == :donation_amount
    end

    def automations
      @automations ||= Church::Automation.event_automations.joins(:choice).merge(Church::Choice.where(id: id))
      @automations
    end

    def automated_events_full?
      @full ||= automations.inject(false) {|is_full, automation| is_full || automation.event.full?(minimum_responses) }
      @full
    end
  end
end
