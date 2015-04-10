class QueuePolicy < ApplicationPolicy

  class Scope < Struct.new(:user, :scope, :context)
    def resolve
      if context[:quick]
        scope.where(quick_list: true)
      else
        scope.all
      end
    end
  end

  def show?
    false
  end

  def update?
    false
  end

  def create?
    false
  end

  def destroy?
    false
  end
end
