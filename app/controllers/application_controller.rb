class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  if Rails.env.production?
    allow_browser versions: :modern
  end

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # 認証していないユーザーでアクセスした場合、ログイン画面にリダイレクト
  before_action :authenticate_user!

  # 認可されていないアクションを実行した場合の処理を定義
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to(root_path, alert: "アクセス権限がありません。")
  end

  def root_redirect_path
    return gpt_models_path       if current_user.admin?
    return new_chat_path         if current_user.normal?
    return new_user_session_path if current_user.blank?
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
end
