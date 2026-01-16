module ChatsHelper
  def message_type_class(message)
    "#{message.message_type}-message"
  end

  def use_http_call?
    Rails.configuration.static_config.use_http_call == true
  end
end
