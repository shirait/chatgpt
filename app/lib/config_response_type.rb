module ConfigResponseType
  VALID_RESPONSE_TYPES = ["http", "websocket"]

  def initialize
    response_type_check!
  end

  def response_type_http?
    Rails.configuration.static_config.response_type == "http"
  end

  def response_type_websocket?
    Rails.configuration.static_config.response_type == "websocket"
  end

  alias_method :use_http_call?, :response_type_http?
  alias_method :use_websocket?, :response_type_websocket?

  private

  def response_type_check!
    return if VALID_RESPONSE_TYPES.include?(Rails.configuration.static_config.response_type)
    raise "response_type は http または websocket のどちらかを指定してください。"
  end
end
