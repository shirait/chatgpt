class ChatChannel < ApplicationCable::Channel
  def subscribed
    message_thread = MessageThread.find(params[:message_thread_id])
    authorize!(:read, message_thread)
    stream_from "chat_#{params[:message_thread_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def authorize!(action, resource)
    ability = Ability.new(current_user)
    raise CanCan::AccessDenied unless ability.can?(action, resource)
  end
end

