class OpenAiChatJob < ApplicationJob
  queue_as :default

  def perform(message_thread_id, user_message_id, send_prev_messages_to_openai_api = false)
    message_thread = MessageThread.find(message_thread_id)
    user_message = Message.find(user_message_id)
    # WebSocket経路ではジョブ内で再取得するため、チェック状態を引き継ぐ
    user_message.send_prev_messages_to_openai_api = send_prev_messages_to_openai_api

    begin
      OpenAiChatCaller.new(message_thread: message_thread, user_message: user_message).call!
      broadcast_message_complete(message_thread_id)
    rescue Faraday::Error => e
      Rails.logger.error "OpenAiChatJob Faraday::Error: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      broadcast_message_error(message_thread_id, "OpenAI APIの利用でエラーが発生しました。繰り返し発生する場合はサーバ管理者に連絡してください。")
    rescue StandardError => e
      Rails.logger.error "OpenAiChatJob StandardError: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      broadcast_message_error(message_thread_id, "想定外のエラーが発生しました。繰り返し発生する場合はサーバ管理者に連絡してください。")
    end
  end

  private

  def broadcast_message_complete(message_thread_id)
    ActionCable.server.broadcast(
      "chat_#{message_thread_id}",
      { type: "message_complete" }
    )
  end

  def broadcast_message_error(message_thread_id, error_message)
    ActionCable.server.broadcast(
      "chat_#{message_thread_id}",
      { type: "message_error", error: error_message }
    )
  end
end
