# OpenAI APIを呼び出してアシスタントメッセージを作成するサービスクラス
class OpenAiChatCaller
  include ConfigResponseType

  def initialize(message_thread:, user_message:)
    @message_thread = message_thread
    @user_message = user_message
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

  def full_content
    # サブクラスで実装する
    raise NoMethodError
  end

  def stub_response(message)
    # サブクラスで実装する
    raise NoMethodError
  end

  def request_to_openai_api(message)
    # サブクラスで実装する
    raise NoMethodError
  end

  def use_stub?
    Rails.configuration.static_config.use_openai_stub == true ||
    ENV["USE_OPENAI_STUB"] == "true"
  end
end
