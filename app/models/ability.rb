class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can :read, :all
    can :summary, TeachingModule
    can :costs, TeachingModule
    can :summary, User
    can :costs, User

    if user.admin?
      can :manage, :all
    end
  end
end
