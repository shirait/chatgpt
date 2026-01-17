# OpenAI APIを呼び出してアシスタントメッセージを作成するサービスクラス
class OpenAiChatCaller
  include ConfigSwitches
  TEMPERATURE = 0.7

  def initialize(message_thread:, user_message:)
    @message_thread = message_thread
    @user_message = user_message
  end

  def full_content
    if Rails.env.development? && use_stub?
      stub_http_response_content = stub_http_response(@user_message)
      return stub_http_response_content if use_http_call?
      return stub_websocket_response(stub_http_response_content) if use_websocket?
    end

    return request_to_openai_api_with_http(@user_message) if use_http_call?
    request_to_openai_api_with_websocket(@user_message) if use_websocket?
  end

  def call!
    Message.create!(
      message_thread_id: @message_thread.id,
      gpt_model_id: @user_message.gpt_model.id,
      message_type: Message.message_types[:assistant],
      content: full_content,
      creator_id: @user_message.creator_id
    )
  end

  private

  # 注意。client.chatメソッド実行でエラーになっても、機密情報漏洩を避けるため、例外の情報はログに残らない。
  # (https://github.com/alexrudall/ruby-openai?tab=readme-ov-file#errors)
  def request_to_openai_api_with_websocket(message)
    access_token = Rails.configuration.static_config.openai_key
    client = OpenAI::Client.new(access_token: access_token)
    full_content = ""

    chunk_index = 0

    client.chat(
      parameters: {
        model: message.gpt_model.name,
        messages: OpenAiMessageBuilder.build(message: message),
        temperature: TEMPERATURE,
        stream: proc do |chunk, _bytesize|
          delta = chunk.dig("choices", 0, "delta", "content")
          if delta
            full_content += delta
            # ActionCableでリアルタイム送信
            ActionCable.server.broadcast(
              "chat_#{@message_thread.id}",
              {
                type: "message_chunk",
                content: delta,
                index: chunk_index
              }
            )
            chunk_index += 1
          end
        end
      }
    )

    full_content
  end

  def request_to_openai_api_with_http(message)
    access_token = Rails.configuration.static_config.openai_key
    client = OpenAI::Client.new(access_token: access_token)

    response = client.chat(
      parameters: {
        model: message.gpt_model.name,
        messages: OpenAiMessageBuilder.build(message: message),
        temperature: TEMPERATURE
      }
    )

    response.dig("choices", 0, "message", "content").to_s
  end

  def use_stub?
    Rails.configuration.static_config.use_openai_stub == true ||
    ENV["USE_OPENAI_STUB"] == "true"
  end

  def stub_http_response(message)
    "Hello, world!(stub message for: #{message.content[0..50]}...)"
  end

  def stub_websocket_response(content)
    # スタブの場合もストリーミング風に送信（文字ごとに送信）
    chunk_index = 0
    content.each_char do |char|
      ActionCable.server.broadcast(
        "chat_#{@message_thread.id}",
        {
          type: "message_chunk",
          content: char,
          index: chunk_index
        }
      )
      chunk_index += 1
      sleep(0.01) # リアルタイム感を出すため少し待機
    end
  end
end
