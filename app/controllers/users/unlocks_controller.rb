# frozen_string_literal: true

class Users::UnlocksController < Devise::UnlocksController
  # ロックは管理者のみ可能とする。
  # 画面上に導線は公開していないが、直接POSTされた場合にエラーを返すようにしておく。
  before_action :raise_error

  # GET /resource/unlock/new
  # def new
  #   super
  # end

  # POST /resource/unlock
  # def create
  #   super
  # end

  # GET /resource/unlock?unlock_token=abcdef
  # def show
  #   super
  # end

  # protected

  # The path used after sending unlock password instructions
  # def after_sending_unlock_instructions_path_for(resource)
  #   super(resource)
  # end

  # The path used after unlocking the resource
  # def after_unlock_path_for(resource)
  #   super(resource)
  # end

  private

  def raise_error
    raise ActionController::RoutingError, "Unlock functionality is not available"
  end
end
