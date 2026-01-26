class TalkChannel < ApplicationCable::Channel
  def subscribed
    @talk_thread = TalkThread.find_by(id: params[:talk_thread_id])
    reject unless @talk_thread
    reject unless allowed_to_stream?

    stream_from("talk_thread_#{@talk_thread.id}")
  end

  private

  def allowed_to_stream?
    return true if current_user.admin?
    @talk_thread.user_id == current_user.id
  end
end
