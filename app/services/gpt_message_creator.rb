class GptMessageCreator
  def initialize(message_thread:, user_message:)
    @message_thread = message_thread
    @user_message = user_message
  end

  def call!
    Message.create!(
      message_thread_id: @message_thread.id,
      gpt_model_id: @user_message.gpt_model.id,
      message_type: Message.message_types[:gpt],
      content: request_to_openai_api(@user_message),
      creator_id: @user_message.creator_id
    )
  end

  private

  # 注意。client.chatメソッド実行でエラーになっても、機密情報漏洩を避けるため、例外の情報はログに残らない。
  # (https://github.com/alexrudall/ruby-openai?tab=readme-ov-file#errors)
  def request_to_openai_api(message)
    access_token = Rails.configuration.static_config.openai_key
    client = OpenAI::Client.new(access_token: access_token)
    response = client.chat(
      parameters: {
        model: message.gpt_model.name,
        messages: [{ role: "user", content: message.content }],
        temperature: 0.7
      }
    )
    response.dig("choices", 0, "message", "content")
  end
end

