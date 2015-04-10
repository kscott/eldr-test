module Church
  class Checkin
    class Event
      attr_accessor :occurrence, :status
      def initialize(occurrence, status = nil)
        @occurrence = occurrence
        @status = status unless status.nil?
      end

      def method_missing(method_name, *args, &block)
        event.send(method_name, *args, &block) if event
      end

      private

        def event
          @event ||= Church::Event.find(occurrence.id)
        end
    end
  end
end
