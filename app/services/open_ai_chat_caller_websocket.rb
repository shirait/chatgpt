class OpenAiChatCallerWebsocket < OpenAiChatCaller
  private

  def full_content
    return stub_response(@user_message) if Rails.env.development? && use_stub?
    request_to_openai_api(@user_message)
  end

  # 注意。client.chatメソッド実行でエラーになっても、機密情報漏洩を避けるため、例外の情報はログに残らない。
  # (https://github.com/alexrudall/ruby-openai?tab=readme-ov-file#errors)
  def request_to_openai_api(message)
    access_token = Rails.configuration.static_config.openai_key
    client = OpenAI::Client.new(access_token: access_token)
    full_content = ""

    chunk_index = 0

    client.chat(
      parameters: {
        model: message.gpt_model.name,
        messages: OpenAiMessageBuilder.build(message: message),
        temperature: message.gpt_model.temperature,
        stream: proc do |chunk, _bytesize|
          delta = chunk.dig("choices", 0, "delta", "content")
          if delta
            full_content += delta
            broadcast_message_chunk(delta, chunk_index)
            chunk_index += 1
          end
        end
      }
    )

    full_content
  end

  def broadcast_message_chunk(delta, chunk_index)
    ActionCable.server.broadcast(
      "chat_#{@message_thread.id}",
      {
        type: "message_chunk",
        content: delta,
        index: chunk_index
      }
    )
  end

  def stub_response(message)
    # スタブの場合もストリーミング風に送信（文字ごとに送信）
    content = "Hello, world!(stub message for: #{message.content[0..50]}...)"
    chunk_index = 0
    content.each_char do |char|
      broadcast_message_chunk(char, chunk_index)
      chunk_index += 1
      sleep(0.01)
    end
    content
  end
end
