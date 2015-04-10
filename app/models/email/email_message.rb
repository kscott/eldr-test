module Email
  class EmailMessage < ::Email::Base
    self.table_name = "email_messages"

    serialize :delivery_complete, CustomDateTimeSerializer

    before_save(on: :create) do
      self.delivery_complete = "" unless self.delivery_complete
    end

    has_many :recipients, class_name: "EmailRecipient"
  end
end
