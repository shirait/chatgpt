module TalksHelper
  def talk_message_direction_class(message)
    message.sender_id == current_user.id ? "is-flex-direction-row-reverse" : ""
  end

  def talk_message_box_class(message)
    message.sender_id == current_user.id ? "user-message" : "assistant-message"
  end
end
