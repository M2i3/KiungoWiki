class Ability
  include CanCan::Ability

  def initialize(user)

    wiki_entities = [Artist, Work, Release, Recording, Category]
   
    wiki_entities.each{|wiki_entity|
      can [:read, :portal, :recent_changes, :search, :alphabetic_index], wiki_entity       
    }

    can :read, PortalArticle, :publish_date.lte => Time.now

    if user
      if user.groups.include?("user")
        wiki_entities.each{|wiki_entity|
          can :manage, wiki_entity       
        }
      end

      if user.groups.include?("super-admin")
        can :manage, :all
      end
      can :manage, Possession, owner: user
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
