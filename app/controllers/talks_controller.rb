class TalksController < ApplicationController
  def show
    load_users_for_admin
    @selected_user = selected_user
    return if @selected_user.nil?

    @talk_thread = TalkThread.find_or_create_by!(user_id: @selected_user.id)
    authorize!(:read, @talk_thread)
    @talk_messages = @talk_thread.talk_messages.includes(:sender).order(:id)
  end

  def create_message
    @selected_user = selected_user
    if @selected_user.nil?
      render(json: { error: "ユーザーが存在しません。" }, status: :unprocessable_entity) and return
    end

    @talk_thread = TalkThread.find_or_create_by!(user_id: @selected_user.id)
    @talk_message = @talk_thread.talk_messages.build(
      content: params[:content],
      sender_id: current_user.id
    )
    authorize!(:create, @talk_message)

    if @talk_message.save
      broadcast_message(@talk_message)
      head :ok
    else
      render(json: { error: @talk_message.errors.full_messages.join("\n") }, status: :unprocessable_entity)
    end
  end

  private

  def load_users_for_admin
    @users = current_user.admin? ? User.normal.order(:id) : []
  end

  def selected_user
    return current_user if current_user.normal?
    return User.normal.find_by(id: params[:user_id]) if params[:user_id].present?

    User.normal.order(:id).first
  end

  def broadcast_message(message)
    ActionCable.server.broadcast(
      "talk_thread_#{message.talk_thread_id}",
      {
        type: "talk_message",
        message: {
          id: message.id,
          content: message.content,
          sender_id: message.sender_id,
          sender_name: message.sender.name,
          created_at: I18n.l(message.created_at, format: :short)
        }
      }
    )
  end
end
