class UserGigPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end

  def show?
    return record.user_id == user.id
  end

  def new?
    return create?
  end

  def create?
    return true
  end

  def index?
    return true
  end

  def destroy?
    return record.user_id == user.id
  end

  def edit?
    return update?
  end

  def update?
    return record.user_id == user.id
  end
end
