module Church
  class ScheduleDetailAssignment < ::Church::Base
    self.table_name = "schedule_detail_assignments"
    belongs_to :individual
    belongs_to :schedule_detail_position, foreign_key: :schedule_detail_positions_id
    has_one :position, through: :schedule_detail_position
    scope :current, -> { eager_load(schedule_detail_position: :schedule_detail_calendar_items).where("schedule_detail_calendar_items.datetime_end >= '#{Time.now}'").distinct }

    STATUS = {
      confirmed: "confirmed",
      unconfirmed: "unconfirmed",
      declined: "declined",
      removed: "removed",
      not_sent: "not sent"
    }

    def times
      schedule_detail_position.schedule_detail_calendar_items.order(:datetime_start)
    end

    def date
      times.service_times.first.datetime_start.strftime("%F")
    end

    def update_response(attributes)
      attributes[:status] = STATUS[attributes[:status]]
      params = ActionController::Parameters.new(status: attributes[:status], note: attributes[:note]).permit(:status, :note)
      self.assign_attributes(params)
      self.save!
    end
  end
end
