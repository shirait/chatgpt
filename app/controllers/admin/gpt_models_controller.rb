class Admin::GptModelsController < ApplicationController
  load_and_authorize_resource

  def index
    @gpt_models = GptModel.all
  end

  def new
    @gpt_model = GptModel.new
  end

  def create
    @gpt_model = GptModel.build_gpt_model(gpt_model_params, creator_id: current_user.id)
    if @gpt_model.save && inactive_other_gpt_models
      flash[:notice] = "#{@gpt_model.name}を作成しました。"
      redirect_to admin_gpt_models_path
    else
      flash.now[:alert] = t("errors.messages.not_saved", resource: t("activerecord.models.gpt_model"))
      render :new
    end
  end

  def show
    @gpt_model = GptModel.find(params[:id])
  end

  def edit
    @gpt_model = GptModel.find(params[:id])
  end

  def update
    @gpt_model.assign_attributes(gpt_model_params)
    if @gpt_model.save && inactive_other_gpt_models
      flash[:notice] = "#{@gpt_model.name}を更新しました。"
      redirect_to admin_gpt_models_path
    else
      flash.now[:alert] = "入力に問題があります。エラー内容を確認してください。"
      render :edit
    end
  end

  def destroy
    @gpt_model = GptModel.find(params[:id])
    if @gpt_model.messages.exists?
      flash[:alert] = "#{@gpt_model.name}はユーザーがメッセージを作成済みのため、削除できません。"
      redirect_to admin_gpt_models_path and return
    end

    @gpt_model.destroy!
    flash[:notice] = "#{@gpt_model.name}を削除しました。"
    redirect_to admin_gpt_models_path
  end

  private

  def inactive_other_gpt_models
    if @gpt_model.active?
      GptModel.where.not(id: @gpt_model.id).update(active: false)
    end
    true
  end

  def gpt_model_params
    params.require(:gpt_model).permit(:name, :description, :active)
  end
end
