# Be sure to restart your server when you modify this file.

if Rails.env.test?
  # テスト環境ではRedis不要のためCookie Storeを使用
  Rails.application.config.session_store :cookie_store,
    key: "_chatgpt_session"
else
  # development/productionではRedisをセッションストアとして使用
  redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/1")
  session_redis_url = "#{redis_url}/session"

  Rails.application.config.session_store :redis_store,
    servers: [session_redis_url],
    expire_after: 90.minutes,
    key: "_chatgpt_session",
    threadsafe: true,
    secure: Rails.env.production?
end
