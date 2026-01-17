class Admin::UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.build_user(user_params, creator_id: current_user.id)
    if @user.save
      flash[:notice] = "#{@user.email}を作成しました。"
      redirect_to admin_user_path(@user)
    else
      flash.now[:alert] = "入力に問題があります。エラー内容を確認してください。"
      render(:new, status: :unprocessable_entity)
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.assign_update_attributes(user_params, updater_id: current_user.id)
    if @user.save
      flash[:notice] = "#{@user.email}を更新しました。"
      redirect_to(admin_user_path(@user))
    else
      flash.now[:alert] = "入力に問題があります。エラー内容を確認してください。"
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      flash[:notice] = "#{@user.email}を削除しました。"
      redirect_to(admin_users_path)
    else
      flash.now[:alert] = "入力に問題があります。エラー内容を確認してください。"
      render(:show, status: :unprocessable_entity)
    end
  end

  def search
    @users = User.all
    if params[:name].present?
      @users = @users.where("name LIKE ?", "%#{params[:name]}%")
    end

    if params[:email].present?
      @users = @users.where("email LIKE ?", "%#{params[:email]}%")
    end

    if params[:role].present? && params[:role].in?(User.roles.keys)
      @users = @users.where(role: params[:role])
    end

    if params[:active].present? && params[:active].in?([ "1", "0" ])
      @users = @users.where(active: params[:active] == "1")
    end

    render :index
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :active)
  end
end
