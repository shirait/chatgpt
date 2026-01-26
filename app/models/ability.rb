# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # 未ログインの場合は全ての権限を拒否
    return if user.blank?

    send("#{user.role}_abilities", user)
  end

  def admin_abilities(user)
    can(:manage, GptModel)
    can(:manage, User)
    can(:manage, TalkThread)
    can(:manage, TalkMessage)
  end

  def normal_abilities(user)
    can(:manage, MessageThread, creator_id: user.id)
    can(:manage, Message,       creator_id: user.id)
    can(:manage, Tag,           creator_id: user.id)
    can(:read, TalkThread, user_id: user.id)
    can(:read, TalkMessage, talk_thread: { user_id: user.id })
    can(:create, TalkMessage, sender_id: user.id, talk_thread: { user_id: user.id })
  end
end
