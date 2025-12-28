module ApplicationHelper
  def need_toplevel_flash_messages?
    !not_need_toplevel_flash_messages?
  end

  def not_need_toplevel_flash_messages?
    params[:controller] == "message_threads" && params[:action] == "add_message"
  end
end
