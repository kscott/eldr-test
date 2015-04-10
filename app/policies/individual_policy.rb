class IndividualPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope, :context)
  end

  def show?
    record.led_by? user
  end

  def update?
    record.led_by? user
  end
end
