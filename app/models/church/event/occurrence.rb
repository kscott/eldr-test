module Church
  class Event
    class Occurrence < Struct.new(:id, :name, :occurrence, :day_of_week, :attendance_taken, :total_attendees)
      def initialize(*)
        super
        self.attendance_taken ||= false
        self.total_attendees ||= 0
        unless self.day_of_week
          self.day_of_week = occurrence.strftime("%A") if occurrence
        end
      end

      def to_time
        occurrence.to_time
      end

      def time
        occurrence.strftime("%-I:%M%p").sub(/(a|p)m/i, "\\1").downcase
      end

      def room_name
        event.checkin_display_name
      end

      def group_name
        event.group_name
      end

      def event_id
        event.id
      end

      def event
        @event ||= Church::Event.find(id)
      end

      def event=(event)
        @event = event
        self.id = @event.id
        self.name = @event.name
        self.occurrence = nil
        self.day_of_week = nil
        self.attendance_taken = false
        self.total_attendees = 0
      end
    end
  end
end
