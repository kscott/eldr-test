module Church
  class NoteSerializer < ::Church::BaseSerializer
    schema do
      type "note"
      map_properties :id, :sharing_level
      property :date, item.date.strftime("%Y-%m-%d")
      property :type, item.context
      property :content, item.note
      entity item.context.sub(" ", "").underscore.to_sym, context_object, context_serializer
      entity :creator, item.creator, Church::MinimalIndividualSerializer
      link :edit, href: individual_notes_path(item.individual, item.id), authorized: NotePolicy.new(current_individual, item).update?
      link :delete, href: individual_notes_path(item.individual, item.id), authorized: NotePolicy.new(current_individual, item).destroy?
    end

    protected

    def context_object
      item.context_object
    end

    def context_serializer
      case item.context
      when "General"
        Church::MinimalIndividualSerializer
      when "Coach"
        Church::BasicGroupSerializer
      when "Leader"
        Church::BasicGroupSerializer
      when "Process Queue"
        Church::BasicQueueSerializer
      end
    end
  end
end
