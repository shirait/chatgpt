module ConfigResponseType
  VALID_RESPONSE_TYPES = [ "http", "websocket" ]

  def initialize(*)
    super
    response_type_check!
  end

  # response_type_http? や response_type_websocket? を定義
  VALID_RESPONSE_TYPES.each do |type|
    define_method "response_type_#{type}?" do
      Rails.configuration.static_config.response_type == type
    end
  end

  private

  def response_type_check!
    return if VALID_RESPONSE_TYPES.include?(Rails.configuration.static_config.response_type)
    raise "response_type は http または websocket のどちらかを指定してください。"
  end
end
