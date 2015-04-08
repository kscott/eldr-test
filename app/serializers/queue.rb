module Serializers
  module Queue
    def basic_queue_profile(queue)
      properties do |p|
        p.id queue.id
        p.name queue.name
      end
      link :self, href: queue_path(queue), authorized: QueuePolicy.new(current_individual, queue).show?
    end
  end
end
