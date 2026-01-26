module TalksHelper
  def talk_message_direction_class(message)
    message.sender_id == current_user.id ? "is-flex-direction-row-reverse" : ""
  end

  def talk_message_box_class(message)
    message.sender_id == current_user.id ? "user-message" : "assistant-message"
  end

  def talk_to_user_name
    if current_user.admin?
      @selected_user.name
    else
      "管理者"
    end
  end
end
