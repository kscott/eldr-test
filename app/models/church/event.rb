module Church
  class Event < ::Church::Base
    self.table_name = "event"
    has_many :group_events
    has_many :groups, through: :group_events
    has_many :exceptions, foreign_key: 'event_id', class_name: 'EventException'
    has_many :attendees, foreign_key: 'event_id', class_name: 'EventAttendee'
    has_many :guests, -> { includes(:individual).where.not(individual: {inactive: 1}) }, foreign_key: 'event_id', class_name: 'EventGuest'
    has_many :summaries, foreign_key: 'event_id', class_name: 'EventSummary'
    has_many :automations, -> { where(form_automation_rev: {automation_type_id: Church::Automation.automation_type_ids[:event_automation]}) }, foreign_key: :target_id
    belongs_to :organizer, foreign_key: 'owner_id', class_name: 'Individual'
    belongs_to :attendance_grouping, foreign_key: :grouping_id

    scope :could_occur_between, ->(starting, ending) do
      eager_load(:exceptions).where("(recur != 1 AND (datetime_start BETWEEN :starting AND :ending OR datetime_end BETWEEN :starting AND :ending)) OR (recur = 1 AND datetime_start <= :ending AND (recur_end_date = '20311231' OR recur_end_date >= :yyyymmdd))", starting: starting, ending: ending, yyyymmdd: starting.strftime('%Y%m%d'))
    end

    def start_time
      timezone.local_to_utc(datetime_start).in_time_zone(timezone) if datetime_start
    end

    def end_time
      timezone.local_to_utc(datetime_end).in_time_zone(timezone) if datetime_end
    end

    def until
      if recur_end_date
        if recur_end_date == '20311231'
          nil
        else
          timezone.local_to_utc(Time.parse(recur_end_date)).in_time_zone(timezone)
        end
      end
    end

    def timezone
      if campus
        @timezone ||= ActiveSupport::TimeZone.new(campus.timezone)
      else
        @timezone ||= ActiveSupport::TimeZone.new("America/Denver")
      end
      @timezone
    end

    def forms
      automations.automated_forms
    end

    def occurrences(starting, ending = starting)
      starting = starting.beginning_of_day
      ending = ending.end_of_day

      schedule = self.to_schedule
      dates = schedule.occurrences_between(starting, ending)

      o = []
      dates.map do |date|
        o << Event::Occurrence.new(self.id, self.name, date.to_time, date.strftime("%A"), nil, nil)
      end

      o
    end

    def self.for_department(department)
      joins(:groups).where(groups: {department: department})
    end

    def self.for_group_type(group_type)
      joins(:groups).where(groups: {group_type: group_type})
    end

    def self.for_attendance_grouping(attendance_grouping)
      where(attendance_grouping: attendance_grouping)
    end

    def self.starting_at(time)
      time = Time.parse(time).strftime("%H:%M:%S")

      includes(:exceptions).where("TIME(event.datetime_start) = ?", time)
    rescue
      self.none
    end

    def limited?
      ! unlimited?
    end

    def unlimited?
      registration_limit.to_f.infinite?
    end

    def registration_limit
      attend_max_quantity.zero? ? Float::INFINITY : attend_max_quantity
    end

    def registration_count
      guests.reduce(0) {|sum, guest| sum + guest.quantity }
    end

    def unmatched_registration_count
      automations.includes(:question).inject(0) {|sum, automation| sum + automation.registration_count(automation.unmatched_responses) }
    end

    def remaining_registration
      registration_limit - (registration_count + unmatched_registration_count)
    end

    def full?(requested = 0)
      (remaining_registration - requested) < 1
    end

    def register_via_form?
      forms.count > 0
    end
    def registration_form
      if register_via_form?
        EventRegistrationFormSelector.resolve(self)
      else
        false
      end
    end

    def registration_status
      if !register_via_form?
        :open
      elsif !registration_form
        :closed
      else
        :open
      end
    end

    def self.occurrences_between(collection, starting, ending)
      possible_events = collection.includes(:exceptions).could_occur_between(starting, ending)
      event_ids = possible_events.ids
      summaries = Church::EventSummary.summaries_for_events(event_ids, starting, ending).to_a
      occurrences = []

      possible_events.each do |event|
        starting_time = starting.in_time_zone(event.timezone).beginning_of_day
        ending_time = ending.in_time_zone(event.timezone).end_of_day

        schedule = event.to_schedule
        dates = schedule.occurrences_between(starting_time, ending_time)

        dates.map do |date|
          summary = summaries.find { |element| element.event_id == event.id && element.occurrence == date }
          total_attendance = summary ? summary.total_attendance : 0
          attendance_taken = summary ? summary.attendance_taken? : false

          occurrences << Event::Occurrence.new(event.id, event.name, date, date.strftime("%A"), attendance_taken, total_attendance)
        end
      end


      occurrences.sort_by!(&:occurrence)

      occurrences
    end

    def process_attendance_params(attendance_params)
      attendance_params[:yyyymmdd] = attendance_params[:yyyymmdd].change(hour: datetime_start.hour, min: datetime_start.min)
      attendance_params[:status] = attendance_params[:did_not_meet] ? EventSummary.status_ids['did_not_meet'] : EventSummary.status_ids['complete']
      attendance_params[:summary] = attendance_params.fetch(:summary)
      attendance_params[:send_to] = attendance_params.fetch(:send_to)

      attendance_params
    end

    def save_response(rsvp_params)
      is_create = EventGuest.response_for_individual(self.id, rsvp_params[:individual].id) ? false : true
      guest = EventGuest.where(event: self, individual: rsvp_params[:individual]).first_or_initialize
      guest.comment = rsvp_params[:message]
      guest.status = rsvp_params[:status]
      guest.quantity = rsvp_params[:quantity]

      guests << guest
      save!

      send_rsvp_email(guest) if send_notification?

      is_create ? :create : :update
    end

    def save_attendance(attendance_params)
      params = process_attendance_params(attendance_params)
      is_create = EventSummary.for_occurrence(id, params[:yyyymmdd]) ? false : true
      visitor_count = params[:head_count] ? params[:head_count] : params[:visitors]
      email_params = {}

      raise "Attendees must be empty when they did not meet" if params[:did_not_meet] && (params[:attendees].size > 0 || visitor_count > 0)
      raise "Must provide attendees or visitor count" if !params[:did_not_meet] && (params[:attendees].size == 0 && visitor_count == 0)

      if is_create
        attendance = create_attendance(params)
      else
        attendance = update_attendance(params)
      end

      email_params = {
        head_count: attendance[:visitors],
        attendees: attendance[:attendees],
        send_to: params[:send_to],
        summary: attendance[:summary]
      }

      send_attendance_email(email_params)

      is_create ? :create : :update
    end

    def update_attendance(attendance)
      new_attendees = []
      if attendance.key?(:head_count)
        attendance[:visitors] = attendance[:head_count]
      end

      if attendance.key?(:did_not_meet) && attendance[:did_not_meet]
        Church::EventAttendee.where(occurrence: attendance[:yyyymmdd], event_id: id).delete_all
      else
        if attendance.key?(:attendees)
          Church::EventAttendee.where.not(individual_id: 0).where(occurrence: attendance[:yyyymmdd], event_id: id).delete_all

          attendance[:attendees].each do |attendee_id|
            attendee = EventAttendee.create(occurrence: attendance[:yyyymmdd], event_id: id, individual_id: attendee_id, quantity: 1)
            new_attendees << attendee.individual
          end
        else
          new_attendees = Church::EventAttendee.where.not(individual_id: 0).where(occurrence: attendance[:yyyymmdd], event_id: id).map(&:individual)
        end

        if attendance.key?(:visitors)
          if attendance[:visitors] > 0
            EventAttendee.where(occurrence: attendance[:yyyymmdd], event_id: id, individual_id: 0).delete_all
            EventAttendee.create(occurrence: attendance[:yyyymmdd], event_id: id, individual_id: 0, quantity: attendance[:visitors])
          else
            EventAttendee.where(occurrence: attendance[:yyyymmdd], event_id: id, individual_id: 0).delete_all
          end
        end
      end

      summary = EventSummary.where(occurrence: attendance[:yyyymmdd], event_id: id).first
      if attendance.key?(:did_not_meet)
        summary.status_id = attendance[:status]
      end
      if attendance[:summary].key?(:topic)
        summary.topic = attendance[:summary][:topic]
      end
      if attendance[:summary].key?(:notes)
        summary.notes_general = attendance[:summary][:notes]
      end
      if attendance[:summary].key?(:prayer_requests)
        summary.notes_prayer_praise = attendance[:summary][:prayer_requests]
      end
      if attendance[:summary].key?(:people_information)
        summary.notes_people = attendance[:summary][:people_information]
      end
      summary.save!

      {summary: summary, attendees: new_attendees, visitors: (attendance[:visitors] || 0)}
    end

    def create_attendance(attendance)
      new_attendees = []
      visitor_count = attendance[:head_count] ? attendance[:head_count] : attendance[:visitors]
      Church::EventAttendee.where(occurrence: attendance[:yyyymmdd], event_id: id).delete_all

      unless attendance[:did_not_meet]
        attendance[:attendees].each do |attendee_id|
          attendee = EventAttendee.create(occurrence: attendance[:yyyymmdd], event_id: id, individual_id: attendee_id, quantity: 1)
          new_attendees << attendee.individual
        end

        if visitor_count > 0
          EventAttendee.create(occurrence: attendance[:yyyymmdd], event_id: id, individual_id: 0, quantity: visitor_count)
        end
      end

      summary = EventSummary.create(
        occurrence: attendance[:yyyymmdd],
        event_id: id,
        group_id: group.id,
        status_id: attendance[:status],
        topic: attendance[:summary][:topic],
        notes_general: attendance[:summary][:notes],
        notes_prayer_praise: attendance[:summary][:prayer_requests],
        notes_people: attendance[:summary][:people_information]
      )

      {summary: summary, attendees: new_attendees, visitors: (visitor_count || 0)}
    end

    def send_rsvp_email(guest)
      email = Email::EventController.new
      subject = "#{guest.individual.name} RSVP'd #{guest.printable_status} for #{guest.event.name}"

      email.context = {
        event: self,
        guest: guest,
        event_url: "#{Company::OrganizationApplication.current.base_url}/event_detail.php?event_id=#{id}",
        rsvp_status: guest.printable_status,
        subject: subject,
        campus: campus,
        organization: Company::OrganizationApplication.current
      }

      message = Email::Message.new(
        subject: subject,
        body: email.rsvp_notification,
        sender: Individual.current.to_sender
      )

      recipients = [Email::Recipient.new(organizer.to_email)]

      Email.send(recipients: recipients, message: message)
    end

    def send_attendance_email(send_to:, summary:, head_count: 0, attendees: [])
      recipients = []
      return if send_to == :none

      case send_to
      when :participants
        group.participants.each do |participant|
          recipients << Email::Recipient.new(
            participant.individual.to_email
          )
        end
      when :leaders
        group.leaders.each do |leader|
          recipients << Email::Recipient.new(
            leader.individual.to_email
          )
        end
        if Company::OrganizationApplication.current.has_module?(:mod_group_structure_on)
          if group.director
            recipients << Email::Recipient.new(group.director.to_email)
          end
          if group.coach
            recipients << Email::Recipient.new(group.coach.to_email)
          end
        end
      end

      recipients.uniq! { |r| r.recipient[:email] }
      recipients.reject! {|r| r.recipient[:email].blank? } unless recipients.empty?

      return if recipients.empty?

      if group.individuals.size <= 1000
        absent_participants = group.individuals.where.not(id: attendees.map(&:id))
      end

      attendance_email = Email::AttendanceController.new
      subject = "Event summary for #{name}"

      attendance_email.context = {
        event: self,
        subject: subject,
        summary: summary,
        attendees: attendees,
        absent_participants: absent_participants,
        head_count: head_count,
        campus: campus,
        organization: Company::OrganizationApplication.current
      }

      message = Email::Message.new(
        subject: subject,
        body: attendance_email.summary,
        sender: Individual.current.to_sender
      )

      if Email.send(recipients: recipients, message: message)
        summary.update(
          email_to: EventSummary::EMAIL_TO_STATUS[send_to],
          email_date_last_sent: Time.now
        )
      end
    end

    def group
      @group ||= groups.first
    end

    def group_name
      group.name
    end

    def campus
      if group
        group.campus
      end
    end

    def campus_name
      campus.name
    end

    def total_attendees(date)
      attendees.for_occurrence(date).size
    end

    def allow_other_guests?
      invite_hide_total_count != "1"
    end

    def show_guest_list?
      !hide_guest_list?
    end

    def hide_guest_list?
      invite_hide_guest_list == "1"
    end

    def checkin_display_name
      room_description.blank? ? name : room_description
    end

    def send_notification?
      notification == "1"
    end

    def yes_phrase
      custom_yes.empty? ? "Yes" : custom_yes
    end

    def no_phrase
      custom_no.empty? ? "No" : custom_no
    end

    def maybe_phrase
      custom_maybe.empty? ? "Maybe" : custom_maybe
    end

    def who_phrase
      custom_who.empty? ? "Who is coming?" : custom_who
    end

    def guest_list
      @guest_list ||= guests.includes(:individual)
    end

    def rules
      rule = RULES.fetch(recur_frequency) { :no_rule }

      if rule == :no_rule
        []
      else
        [rule.new(self).to_hash]
      end
    end

    def exception_times
      exceptions.map do |exception|
        ::Time.parse("#{exception.yyyymmdd}T#{datetime_start.strftime("%H:%M:00")}")
      end
    end

    def attendance_for_occurrence(occurrence)
      raise "This event [#{occurrence}] isn't scheduled to meet on this date" unless to_schedule.occurs_on?(occurrence)
      raise "Attendance cannot be taken for a future event" unless occurrence <= Time.now.end_of_day

      individuals = Church::EventAttendee.for_occurrence(id, occurrence)
      summary = Church::EventSummary.for_occurrence(id, occurrence)

      unless summary
        summary = Church::EventSummary.new
      end

      occurrence = occurrence.change(hour: datetime_start.hour, min: datetime_start.min)

      AttendancePresenter.new(event: self, occurrence: occurrence, attendees: individuals, summary: summary)
    end

    def schedule_hash
      {
        start_time: start_time,
        end_time: end_time,
        rrules: rules,
        extimes: exception_times
      }
    end

    def to_schedule
      ::Schedule.new(schedule_hash)
    end

    class AttendancePresenter
      attr_reader :event_id, :occurrence, :status, :head_count, :attendees, :summary, :event

      def initialize(event:, attendees:, summary:, occurrence:)
        @event = event
        @event_id = event.id
        @occurrence = "#{occurrence.strftime("%Y-%m-%d")} #{event.datetime_start.strftime("%H:%M:%S")}"
        @status = summary.status
        @head_count = find_head_count(attendees)
        @attendees = attendees.reject {|attendee| attendee.individual_id == 0}
        @summary = summary
      end

      private

      def find_head_count(attendees)
        head_count_records = attendees.reject { |attendee| attendee.individual_id != 0 }
        head_count_record = head_count_records.first
        quantity = head_count_record.quantity if head_count_record

        quantity = 0 unless quantity

        quantity
      end
    end

    module UntilTime
      def until_time
        @event.until
      end
    end

    class DailyRule
      include UntilTime

      def initialize(event)
        @event = event
      end

      def frequency
        :daily
      end

      def to_hash
        {
          frequency: frequency,
          interval: interval,
          until: until_time
        }
      end

      private

      def interval
        @event.recur_interval
      end
    end

    class WeeklyRule
      include UntilTime

      def initialize(event)
        @event = event
      end

      def to_hash
        {
          frequency: frequency,
          interval: interval,
          validations: validations,
          until: until_time
        }
      end

      private

      def frequency
        :weekly
      end

      def interval
        @event.recur_interval
      end

      def frequency_modifiers
        @frequency_modifiers ||= @event.recur_freq_modifier.split
      end

      def validations
        weekday = frequency_modifiers.map do |abbreviated_weekday|
          ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'].grep(/^#{abbreviated_weekday}/i).first.to_sym
        end

        {
          day: weekday
        }
      end
    end

    class MonthlyByWeekdayRule
      include UntilTime

      def initialize(event)
        @event = event
      end

      def to_hash
        {
          frequency: frequency,
          interval: interval,
          validations: validations,
          until: until_time
        }
      end

      private

      def frequency
        :monthly
      end

      def interval
        1
      end

      def frequency_modifiers
        @frequency_modifiers ||= @event.recur_freq_modifier.scan(/\d[+-]\s+[A-Z]{2}/)
      end

      def validations
        weekdays = frequency_modifiers.map do |modifier|
          m = modifier.split
          week = m.first
          abbreviated_weekday = m.last
          full_weekday = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'].grep(/^#{abbreviated_weekday}/i).first.to_sym

          week_interval = week[0].to_i
          if week.include?('-')
            [full_weekday, week_interval * -1]
          else
            [full_weekday, week_interval]
          end
        end

        weekday_hash = weekdays.inject(Hash.new{ |h, k| h[k] = [] }) do |h, (k, v)|
          h[k] << v
          h
        end

        {
          day_of_week: weekday_hash
        }
      end
    end

    class MonthlyByDayRule
      include UntilTime

      def initialize(event)
        @event = event
      end

      def to_hash
        {
          frequency: frequency,
          interval: interval,
          validations: validations,
          until: until_time
        }
      end

      private

      def frequency
        :monthly
      end

      def interval
        1
      end

      def frequency_modifier
        Array(@event.recur_freq_modifier.to_i)
      end

      def validations
        {
          day_of_month: frequency_modifier
        }
      end
    end

    private

    RULES = {
      'D' => DailyRule,
      'MD' => MonthlyByDayRule,
      'MP' => MonthlyByWeekdayRule,
      'W' => WeeklyRule
    }

    private
  end
end
