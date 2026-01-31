# Move this require to your `config/application.rb` if you want to be notified from runner commands too.
require "exception_notification/rails"
require "exception_notification/rake"

# メール設定を外部ファイルから読み込む
email_config = Rails.application.config_for(:email)
exception_notification_config = email_config[:exception_notification]

ExceptionNotification.configure do |config|
  config.add_notifier :email, {
    email_prefix: exception_notification_config[:email_prefix],
    sender_address: exception_notification_config[:from_address],
    exception_recipients: exception_notification_config[:to_address],
    sections: %w[request session backtrace]
  }
end
