class ApplicationPolicy
  attr_reader :user, :record, :context

  def initialize(user, record, context = {})
    @user = user
    @record = record
    @context = context
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end
  alias_method :new?, :create?

  def update?
    false
  end
  alias_method :edit?, :update?

  def destroy?
    false
  end
  alias_method :delete?, :destroy?

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  protected

  def current_organization
    Company::OrganizationApplication.current
  end

  def current_individual
    Church::Individual.current
  end
end

