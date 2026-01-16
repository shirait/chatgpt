module ConfigSwitches
  def use_http_call?
    Rails.configuration.static_config.use_http_call == true
  end

  def use_websocket?
    !use_http_call?
  end
end
