class OpenAiChatJob < ApplicationJob
  queue_as :default

  def perform(message_thread_id, user_message_id)
    message_thread = MessageThread.find(message_thread_id)
    user_message = Message.find(user_message_id)

    begin
      OpenAiChatCaller.new(message_thread: message_thread, user_message: user_message).call!
      # 完了通知を送信
      # ※「ストリーム」を用いてコンテンツ（ブロードキャスト）をサブスクライバに配信している。（Railsガイド参照）
      ActionCable.server.broadcast(
        "chat_#{message_thread_id}",
        {
          type: "message_complete"
        }
      )
    rescue Faraday::Error => e
      Rails.logger.error "OpenAiChatJob Faraday::Error: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      # エラー通知を送信
      ActionCable.server.broadcast(
        "chat_#{message_thread_id}",
        {
          type: "message_error",
          error: "OpenAI APIの利用でエラーが発生しました。繰り返し発生する場合はサーバ管理者に連絡してください。"
        }
      )
    rescue StandardError => e
      Rails.logger.error "OpenAiChatJob StandardError: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      # エラー通知を送信
      ActionCable.server.broadcast(
        "chat_#{message_thread_id}",
        {
          type: "message_error",
          error: "想定外のエラーが発生しました。繰り返し発生する場合はサーバ管理者に連絡してください。"
        }
      )
    end
  end
end
