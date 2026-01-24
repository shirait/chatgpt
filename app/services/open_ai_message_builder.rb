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
      @message.gpt_model.send_prev_messages?
  end

  def prev_messages
    limit = @message.gpt_model.max_prev_message_count * 2
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

    contents = []

    # メッセージ本文
    contents << { type: "text", text: @message.content || "" }

    # 添付ファイル（画像は image_url、その他は text として送信）
    @message.message_files.each do |file|
      if file.content_type.nil? || file.content_type.start_with?("image/")
        content_type = file.content_type || "image/jpeg"
        contents << {
          type: "image_url",
          image_url: {
            url: "data:#{content_type};base64,#{convert_to_base64(file)}"
          }
        }
      else
        # 画像以外（例: docx, pdf 等）はテキスト要素として通知
        contents << {
          type: "text",
          text: "User attached file: #{file.filename}"
        }
      end
    end

    contents
  end

  def convert_to_base64(file)
    Base64.strict_encode64(file.download)
  end
end
