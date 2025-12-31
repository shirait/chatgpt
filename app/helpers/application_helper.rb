module ApplicationHelper
  def need_toplevel_flash_messages?
    !not_need_toplevel_flash_messages?
  end

  def not_need_toplevel_flash_messages?
    params[:controller] == "message_threads" && params[:action] == "add_message"
  end

  # review: スコープを小さくできないか確認（chats_helper.rb に移動できないか確認）
  def message_type_class(message)
    "#{message.message_type.to_s}-message"
  end
end
