module Church
  class FormResponse < ::Church::Base
    self.table_name = "form_response_rev"
    belongs_to :form
    has_many :answers
    scope :unmatched, -> { where(individual_id: 0).includes(:answers) }
    scope :matched, -> { where.not(individual_id: 0).includes(:answers) }

    def satisfies?(automation)
      case automation.matching_type
      when :form
        form_id == automation.form_id
      when :question
        form_id == automation.form_id && answers.where(question: automation.question).any?
      when :choice
        form_id == automation.form_id && answers.where(question: automation.question).any? && answers.where(choice: automation.choice).any?
      when :option
        form_id == automation.form_id && answers.where(question: automation.question).any? && answers.where(choice: automation.choice).any? && answers.where(option: automation.option).any?
      else
        false
      end
    end

    def registration_count(automation, form_id = nil)
      case automation.matching_type
      when :form
        1
      when :question
        answers.where(question: automation.question).inject(0) {|sum, answer| sum + answer.registration_count(automation, form_id) }
      when :choice
        answers.where(choice: automation.choice).inject(0) {|sum, answer| sum + answer.registration_count(automation, form_id) }
      else
        0
      end
    end
  end
end
