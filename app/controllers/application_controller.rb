class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  if Rails.env.production?
    allow_browser versions: :modern
  end

  rescue_from Exception, with: :handle_exception

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # 認証していないユーザーでアクセスした場合、ログイン画面にリダイレクト
  before_action :authenticate_user!

  around_action :collect_sql_queries, if: -> { Rails.env.development? }

  # 認可されていないアクションを実行した場合の処理を定義
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to(root_path, alert: "アクセス権限がありません。")
  end

  def root_redirect_path
    return admin_users_path if current_user.admin?
    return new_chat_path    if current_user.normal?
    new_user_session_path   if current_user.blank?
  end

  def root_redirect
    redirect_to root_redirect_path
  end

  # ログイン後のリダイレクト先
  def after_sign_in_path_for(resource_or_scope)
    root_redirect_path
  end

  # ログアウト後のリダイレクト先
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  private

  def collect_sql_queries
    @executed_sql = []
    callback = lambda do |_name, _start, _finish, _id, payload|
      return if payload[:name] == "SCHEMA"
      return if payload[:name] == "TRANSACTION"

      sql = payload[:sql].to_s.squish
      caller_line = Rails.backtrace_cleaner.clean(caller).find { |line| line.start_with?("app/") }
      @executed_sql << {
        sql: sql,
        name: payload[:name],
        cached: payload[:cached],
        caller: caller_line
      }
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      yield
    end
  end

  def handle_exception(exception)
    ExceptionNotification.notify(exception)
    raise exception
  end
end
