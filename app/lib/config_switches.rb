module ConfigSwitches
  def use_http_call?
    Rails.configuration.static_config.response_type == "http"
  end

  def use_websocket?
    Rails.configuration.static_config.response_type == "websocket"
  end
end
