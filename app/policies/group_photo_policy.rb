class GroupPhotoPolicy < ApplicationPolicy
  def show?
    false
  end

  def update?
    record.leader? user
  end

  def create?
    false
  end

  def destroy?
    false
  end
end
