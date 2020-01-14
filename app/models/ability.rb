class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can :read, :all
    can :show_service, User, id: user.id

    if user.admin?
      can :summary, TeachingModule
      can :summary, User
      can :costs, TeachingModule
      can :costs, User
      can :manage, :all
    end
  end
end
