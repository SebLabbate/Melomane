class CommentPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def new?
    create?
  end

  def create?
    true
  end

  def show?
    return record.user_id == user.id
  end

  def destroy?
    return record.user_id == user.id
  end
end
