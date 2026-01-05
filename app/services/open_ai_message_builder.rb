require "base64"

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
      [ current_user_message ]
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
    content = build_content
    { role: "user", content: content }
  end

  def build_content
    unless @message.message_files.attached?
      return @message.content
    end

    text = [ { type: "text", text: @message.content || "" } ]

    images = @message.message_files.map do |file|
      content_type = file.content_type || "image/jpeg"
      {
        type: "image_url",
        image_url: {
          url: "data:#{content_type};base64,#{convert_to_base64(file)}"
        }
      }
    end

    text + images
  end

  def convert_to_base64(file)
    Base64.strict_encode64(file.download)
  end
end
