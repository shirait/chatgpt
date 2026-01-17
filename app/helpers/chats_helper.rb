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

  def open_hide_link
    if @message_thread.active?
      link_to(t('common.hide'), hide_chat_path(@message_thread), data: { turbo_method: :post, turbo_confirm: t("common.hide_confirm") }, class: "button is-danger is-light is-normal mt-1")
    else
      link_to(t('common.open'), open_chat_path(@message_thread), data: { turbo_method: :post, turbo_confirm: t("common.open_confirm") }, class: "button is-info is-light is-normal mt-1")
    end
  end
end
