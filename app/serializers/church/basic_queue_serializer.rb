module Church
  class BasicQueueSerializer < ::Church::BaseSerializer
    schema do
      type "queue"
      basic_queue_profile item
    end
  end
end
