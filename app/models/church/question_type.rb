module Church
  class QuestionType < ::Church::Base
    self.table_name = "form_question_type_rev"
    def self.inheritance_column
      ""
    end

    def product?
      type == "product"
    end

    def donation_amount?
      type == "donation_amount"
    end
  end
end
