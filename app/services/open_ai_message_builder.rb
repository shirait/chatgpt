class OpenAiMessageBuilder
  def self.build(message:)
    new(message: message).build
  end

  def initialize(message:)
    @message = message
  end

  def build
    if should_include_prev_messages?
      prev_messages.reverse << current_user_message
    else
      [current_user_message]
    end
  end

  private

  def should_include_prev_messages?
    @message.send_prev_messages_to_openai_api? &&
      Rails.configuration.static_config.max_prev_message_count.to_i > 0
  end

  def prev_messages
    limit = Rails.configuration.static_config.max_prev_message_count * 2
    messages = Message.prev_messages(@message, limit)
    messages.map do |msg|
      { role: msg.message_type.to_s, content: msg.content }
    end
  end

  def current_user_message
    { role: "user", content: @message.content }
  end
end

