module Church
  class Note < ::Church::Base
    self.table_name = "note"
    belongs_to :individual
    belongs_to :creator, class_name: Church::Individual

    CONTEXTS = {
      general: "General",
      queue: "Process Queue",
      leader: "Leader",
      coach: "Coach"
    }
    enum sharing_level: [:private_note, :context_note, :leadership_note]

    def context_object
      @context_object ||= case context
      when "Process Queue"
        Church::Queue.find(context_id)
      when "General"
        individual
      when "Leader"
        Church::Group.find(context_id)
      when "Coach"
        Church::Group.find(context_id)
      end
    end
  end
end
