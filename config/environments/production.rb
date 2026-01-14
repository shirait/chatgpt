require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }
  config.active_storage.service = :local
  # config.force_ssl = true
  # リバースプロキシ経由でHTTPSでアクセスされている場合、X-Forwarded-Protoヘッダーを信頼する
  config.assume_ssl = true

  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false

  config.action_mailer.default_url_options = { host: "example.com" }

  config.i18n.fallbacks = true

  config.active_record.dump_schema_after_migration = false

  config.active_record.attributes_for_inspect = [ :id ]

  # Action Cable設定
  # Apache+Passengerでは相対パスを使用（JavaScript側で自動的に正しいURLが生成される）
  # HTTPSを使用している場合は、Apache側でWebSocketプロキシの設定が必要
  config.action_cable.mount_path = "/cable"
  # リバースプロキシ経由でアクセスされる場合、オリジンを許可する必要がある
  # より具体的なオリジン指定も可能: [/https:\/\/www\.terupaki\.shop/]
  config.action_cable.allowed_request_origins = [/http:\/\/.*/, /https:\/\/.*/]
end
