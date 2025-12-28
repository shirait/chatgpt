# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn, :cvv, :cvc
]

# messages.contentは個人情報等を含む場合があるが、ログ出力は行うものとする。
# ただ、DBからmessages.contentを削除してもログに残る問題があるので、ログは定期的に削除するものとする。
