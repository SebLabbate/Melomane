class GigPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end

    def show?
      return true
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
end
