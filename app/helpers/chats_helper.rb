module ChatsHelper
  def message_type_class(message)
    "#{message.message_type}-message"
  end

  def message_background_color(message)
    # return "has-background-primary-light" if message.user?
    # "has-background-link-light" if message.assistant?
  end
end

