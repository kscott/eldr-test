require_relative "schedule_adapter"

class Schedule
  def initialize(original_hash, adapter=ScheduleAdapter::IceCube)
    @adapter = adapter.new(original_hash)
  end

  def occurrences_between(starting, ending)
    @adapter.occurrences_between(starting, ending)
  end

  def occurs_on?(occurrence)
    @adapter.occurs_on?(occurrence)
  end

  def next_occurrence(time = Time.now)
    @adapter.next_occurrence(time)
  end
end

