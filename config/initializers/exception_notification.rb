# Move this require to your `config/application.rb` if you want to be notified from runner commands too.
require "exception_notification/rails"
require "exception_notification/rake"

# メール設定を外部ファイルから読み込む
email_config = Rails.application.config_for(:email)
exception_notification_config = email_config[:exception_notification]

ExceptionNotification.configure do |config|
  # 送信制限: 同じ例外をグループ化し、2**n 回目 (1, 2, 4, 8, 16...) のみ送信
  config.error_grouping = true
  # config.error_grouping_period = 5.minutes
  config.error_grouping_cache = Rails.cache
  config.notification_trigger = lambda { |_exception, count|
    count.positive? && (count & (count - 1)).zero?  # 2**n 回目のみ送信
  }

  config.add_notifier :email, {
    email_prefix: exception_notification_config[:email_prefix],
    sender_address: exception_notification_config[:from_address],
    exception_recipients: exception_notification_config[:to_address],
    sections: %w[request session backtrace]
  }
end
