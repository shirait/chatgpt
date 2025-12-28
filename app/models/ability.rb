# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # 未ログインの場合は全ての権限を拒否
    return if user.blank?

    send("#{user.role}_abilities", user)
  end

  def admin_abilities(user)
    can :manage, :all
  end

  def normal_abilities(user)
    can :manage, MessageThread, creator_id: user.id
    can :manage, Message,       creator_id: user.id
  end
end
