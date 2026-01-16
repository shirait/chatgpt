module ChatsHelper
  include ConfigSwitches
  def message_type_class(message)
    "#{message.message_type}-message"
  end

  def link_message_file(message_file)
    if message_file.content_type&.start_with?("image/")
      image_tag(url_for(message_file), class: "message-file")
    else
      link_to(message_file.filename.to_s,
              url_for(message_file),
              target: "_blank",
              rel: "noopener")
    end
  end
end
