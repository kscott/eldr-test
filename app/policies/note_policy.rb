class NotePolicy < ApplicationPolicy

  class Scope < Struct.new(:user, :scope, :context)
    def resolve
      notes = Church::Note.arel_table
      individual_criteria = notes[:individual_id].eq(context[:individual].id)
      all_leaders_criteria = notes[:sharing_level].eq(Church::Note.sharing_levels["leadership_note"])

      if context[:individual].led_by? user
        if context[:organization].has_module? :mod_private_notes_on
          private_notes = notes[:sharing_level].eq(Church::Note.sharing_levels["private_note"]).and(notes[:creator_id].eq(user.id))
          sharing_level_criteria = all_leaders_criteria.or(private_notes)
        else
          sharing_level_criteria = all_leaders_criteria
        end

        context_criteria = notes[:context].in(["General", "Process Queue"])

        scope.where(individual_criteria.and(sharing_level_criteria).and(context_criteria))
      else
        scope.none
      end
    end
  end

  def show?
    case context[:sharing_level]
    when :private_note
      current_organization.has_module?(:mod_private_notes_on) && record.creator == user
    when :context_note
      current_organization.has_module?(:mod_private_notes_on) && false # Fix this when existing roles are available in API
    when :leadership_note
      note_subject.led_by? user
    end
  end

  def update?
    record.creator == user
  end

  def create?
    case context[:sharing_level]
    when :private_note
      current_organization.has_module? :mod_private_notes_on
    when :context_note
      current_organization.has_module?(:mod_private_notes_on) && false # Fix this when existing roles are available in API
    when :leadership_note
      note_subject.led_by? user
    end
  end

  def destroy?
    record.creator == user
  end

  protected

  def note_subject
    context[:individual]
  end
end
