module Church
  class Need < ::Church::Base
    self.table_name = "need"

    belongs_to :group
    belongs_to :coordinator, class_name: "Individual", foreign_key: "coordinator_id"
    has_many :items, class_name: "NeedItem"

    def assign_item(need_item, individual)
      unless need_item.assigned?
        need_item.assign_to(individual)

        send_assign_coordinator_email(need_item, individual)

        :assigned
      else
        if need_item.assigned_to? individual
          :unchanged
        else
          :unavailable
        end
      end
    end

    def unassign_item(need_item, individual)
      if need_item.assigned_to? individual
        need_item.unassign

        send_unassign_individual_email(need_item, individual)
        send_unassign_coordinator_email(need_item, individual)

        :removed
      else
        :unavailable
      end
    end

    def send_assign_coordinator_email(need_item, individual)
      email = Email::NeedController.new
      subject = "#{name} Item Assignment Info"

      email.context = {
        need: self,
        individual: individual,
        need_item: need_item,
        need_url: "#{Company::OrganizationApplication.current.base_url}/need_detail.php?need_id=#{id}",
        subject: subject,
        campus: group.campus,
        organization: Company::OrganizationApplication.current
      }

      message = Email::Message.new(
        subject: subject,
        body: email.assign_coordinator_notification,
        sender: Individual.current.to_sender
      )

      recipients = [Email::Recipient.new(coordinator.to_email)]

      Email.send(recipients: recipients, message: message)
    end

    def send_unassign_individual_email(need_item, individual)
      email = Email::NeedController.new
      subject = "#{name} Item Assignment Info"

      email.context = {
        need: self,
        need_item: need_item,
        need_url: "#{Company::OrganizationApplication.current.base_url}/need_detail.php?need_id=#{id}",
        subject: subject,
        campus: group.campus,
        organization: Company::OrganizationApplication.current
      }

      message = Email::Message.new(
        subject: subject,
        body: email.unassign_individual_notification,
        sender: Individual.current.to_sender
      )

      recipients = [Email::Recipient.new(individual.to_email)]

      Email.send(recipients: recipients, message: message)
    end

    def send_unassign_coordinator_email(need_item, individual)
      email = Email::NeedController.new
      subject = "#{name} Item Assignment Info"

      email.context = {
        need: self,
        individual: individual,
        need_item: need_item,
        need_url: "#{Company::OrganizationApplication.current.base_url}/need_detail.php?need_id=#{id}",
        subject: subject,
        campus: group.campus,
        organization: Company::OrganizationApplication.current
      }

      message = Email::Message.new(
        subject: subject,
        body: email.unassign_coordinator_notification,
        sender: Individual.current.to_sender
      )

      recipients = [Email::Recipient.new(coordinator.to_email)]

      Email.send(recipients: recipients, message: message)
    end
  end
end
