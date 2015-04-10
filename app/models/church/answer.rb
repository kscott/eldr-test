module Church
  class Answer < ::Church::Base
    self.table_name = "form_response_answer_rev"
    belongs_to :form_response
    belongs_to :question, foreign_key: :form_question_id
    has_one :question_type, through: :question
    belongs_to :choice, foreign_key: :form_question_choice_id
    belongs_to :option

    def satisfies?(automation, form_id = nil)
      unless form_id
        form_id = self.form_id
      end

      case automation.matching_type
      when :form
        form_id == automation.form_id
      when :question
        form_id == automation.form_id && question_id == automation.question_id
      when :choice
        form_id == automation.form_id && question_id == automation.question_id && choice_id == automation.choice_id
      when :option
        form_id == automation.form_id && question_id == automation.question_id && choice_id == automation.choice_id && option_id == automation.option_id
      else
        false
      end
    end

    def form_id
      @form_id ||= self.form_response.form_id
      @form_id
    end

    def question_id
      form_question_id
    end

    def choice_id
      form_question_choice_id
    end

    def registration_count(automation, form_id = nil)
      if satisfies?(automation, form_id)
        if automation.matching_type != :form
          if question_type.type == "product"
            value.to_i
          else
            1
          end
        else
          1
        end
      else
        0
      end
    end
  end
end
