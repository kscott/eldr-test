module Email
  class EmailRecipient < ::Email::Base
    self.table_name = "email_recipients"

    serialize :delivery_complete, CustomDateTimeSerializer

    before_save(on: :create) do
      self.delivery_complete = "" unless self.delivery_complete
    end

    belongs_to :message, class_name: "EmailMessage"
  end
end
