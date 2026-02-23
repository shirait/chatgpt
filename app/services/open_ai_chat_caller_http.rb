class OpenAiChatCallerHttp < OpenAiChatCaller
  private

  def full_content
    return stub_response(@user_message) if Rails.env.development? && use_stub?
    request_to_openai_api(@user_message)
  end

  def request_to_openai_api(message)
    access_token = Rails.configuration.static_config.openai_key
    client = OpenAI::Client.new(access_token: access_token)

    response = client.chat(
      parameters: {
        model: message.gpt_model.name,
        messages: OpenAiMessageBuilder.build(message: message),
        temperature: message.gpt_model.temperature
      }
    )

    response.dig("choices", 0, "message", "content").to_s
  end

  def stub_response(message)
    "Hello, world!(stub message for: #{message.content[0..50]}...)"
  end
end
