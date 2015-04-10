module Church
  class Queue < ::Church::Base
    self.table_name = 'step'
    has_many :individual_queues, table_name: "individual_steps", foreign_key: "step_id"
    has_many :individuals, through: :individual_queues

    def add_individual(individual)
      individual_queue = individual_queues.build(individual: individual)

      individual_queue.status_id = :not_started
      individual_queue.date_due = due_date

      individual_queue.save!
    end

    class Event
      attr_accessor :recur_freq_modifier, :recur_end_date, :recur_interval

      def initialize(frequency_modifier)
        @recur_freq_modifier = frequency_modifier
        @recur_end_date = "20311231"
        @recur_interval = 1
      end
    end

    def due_date
      case queue_date_due_type
      when "relative"
        ::Chronic.parse("in #{queue_time} days")
      when "weekly"
        ::Chronic.parse("#{weekday}")
      when "monthly_day"
        schedule_hash = {
          start_time: Time.now,
          end_time: Time.now,
          rrules: [
            ::Church::Event::MonthlyByWeekdayRule.new(Queue::Event.new("#{queue_week_number} #{queue_weekday}")).to_hash
          ],
          extimes: []
        }

        ::Schedule.new(schedule_hash).next_occurrence
      when "monthly_date"
        schedule_hash = {
          start_time: Time.now,
          end_time: Time.now,
          rrules: [
            ::Church::Event::MonthlyByDayRule.new(Queue::Event.new(queue_time)).to_hash
          ],
          extimes: []
        }

        ::Schedule.new(schedule_hash).next_occurrence
      when "quarterly_day"
        start_end = Time.now - 3.months
        schedule_hash = {
          start_time: start_end,
          end_time: start_end,
          rrules: [
            ::Church::Event::WeeklyRule.new(Queue::Event.new(queue_weekday)).to_hash
          ],
          extimes: []
        }

        occurrences = ::Schedule.new(schedule_hash).occurrences_between(Time.now.beginning_of_quarter, Time.now.end_of_quarter)

        occurrence = single_occurrence(occurrences)
        if occurrence.future?
          occurrence
        else
          next_time = (Time.now + 3.months)
          occurrences = ::Schedule.new(schedule_hash).occurrences_between(next_time.beginning_of_quarter, next_time.end_of_quarter)

          single_occurrence(occurrences)
        end
      when "absolute"
        queue_date_due.to_time
      end
    end

    def single_occurrence(occurrences)
      if queue_week_number == '1-'
        occurrences.pop
      else
        week = queue_week_number.to_i

        if (occurrences.size >= week)
          occurrences[week-1]
        else
          occurrences.pop
        end
      end
    end

    def weekday
      {
        "SU" => :sunday,
        "MO" => :monday,
        "TU" => :tuesday,
        "WE" => :wednesday,
        "TH" => :thursday,
        "FR" => :friday,
        "SA" => :saturday
      }.fetch(queue_weekday) {""}
    end
  end
end
