class GroupPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope, :context)
  end

  def show?
    record.participant? user
  end
end
