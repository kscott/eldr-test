module ScheduleAdapter
  class IceCube
    def initialize(original_hash)
      translated_hash = translate(original_hash)
      @schedule = ::IceCube::Schedule.from_hash(translated_hash)
    end

    def occurrences_between(starting, ending)
      @schedule.occurrences_between(starting, ending)
    end

    def occurs_on?(occurrence)
      @schedule.occurs_on?(occurrence)
    end

    def next_occurrence(time)
      @schedule.next_occurrence(time)
    end

    private

    def translate(original_hash)
      {
        start_time: original_hash.fetch(:start_time),
        end_time: original_hash.fetch(:end_time),
        rrules: recur_rules(original_hash.fetch(:rrules)),
        extimes: original_hash.fetch(:extimes)
      }
    end

    def recur_rules(rrules)
      rrules.map do |rule|
        week_start = rule.fetch(:week_start) { 0 }
        {
          interval: rule.fetch(:interval) { 1 },
          week_start: week_start,
          rule_type: rule_type(rule.fetch(:frequency)),
          validations: validations(rule.fetch(:validations) { {} }, week_start),
          until: rule.fetch(:until) { nil }
        }
      end
    end

    def validations(validations, week_start)
      return_validations = {}
      validations.each do |key, value|
        return_validations[key] = case key
        when :day
          value.map do |day|
            current_index = [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday].index(day)

            ((current_index + 7) - week_start) % 7
          end
        when :day_of_week
          value
        when :day_of_month
          value
        end
      end

      return_validations
    end

    def rule_type(frequency)
      raise "Must provide daily, weekly, or monthly." unless [:daily, :weekly, :monthly].include? frequency

      "IceCube::#{frequency.to_s.camelize}Rule"
    end
  end
end
