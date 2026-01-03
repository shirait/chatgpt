# OpenAI APIを呼び出してアシスタントメッセージを作成するサービスクラス
class OpenAiChatCaller
  def initialize(message_thread:, user_message:)
    @message_thread = message_thread
    @user_message = user_message
  end

  def call!
    full_content = ""

    if Rails.env.development? && use_stub?
      full_content = stub_response(@user_message)
      # スタブの場合もストリーミング風に送信
      stub_stream_response(full_content)
    else
      full_content = request_to_openai_api_with_streaming(@user_message)
    end

    # 最終的なメッセージを保存
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
  def request_to_openai_api_with_streaming(message)
    access_token = Rails.configuration.static_config.openai_key
    client = OpenAI::Client.new(access_token: access_token)
    full_content = ""

    client.chat(
      parameters: {
        model: message.gpt_model.name,
        messages: OpenAiMessageBuilder.build(message: message),
        temperature: 0.7,
        stream: true
      },
      stream: proc do |chunk, _bytesize|
        delta = chunk.dig("choices", 0, "delta", "content")
        if delta
          full_content += delta
          # ActionCableでリアルタイム送信
          ActionCable.server.broadcast(
            "chat_#{@message_thread.id}",
            {
              type: "message_chunk",
              content: delta
            }
          )
        end
      end
    )

    full_content
  end

  def use_stub?
    Rails.configuration.static_config.use_openai_stub == true ||
    ENV["USE_OPENAI_STUB"] == "true"
  end

  def stub_response(message)
    "Hello, world!(stub message for: #{message.content[0..50]}...)"
  end

  def stub_stream_response(content)
    # スタブの場合もストリーミング風に送信（文字ごとに送信）
    content.each_char do |char|
      ActionCable.server.broadcast(
        "chat_#{@message_thread.id}",
        {
          type: "message_chunk",
          content: char
        }
      )
      sleep(0.01) # リアルタイム感を出すため少し待機
    end
  end
end
