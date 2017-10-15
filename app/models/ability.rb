class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.admin?
      can :manage, :all
    else
      can :read, :all
      can :summary, TeachingModule
      can :costs, TeachingModule
      can :summary, User
      can :costs, User
    end
  end
end
