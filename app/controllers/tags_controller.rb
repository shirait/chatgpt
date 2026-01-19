class TagsController < ApplicationController
  load_and_authorize_resource

  def index
    @tags = Tag.accessible_by(current_ability).order(id: :asc)
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.build_tag(tag_params, creator_id: current_user.id)
    if @tag.save
      flash[:notice] = "#{@tag.name}を作成しました。"
      redirect_to(tag_path(@tag))
    else
      flash.now[:alert] = "入力に問題があります。エラー内容を確認してください。"
      render(:new, status: :unprocessable_entity)
    end
  end

  def show
    @tag = Tag.find(params[:id])
  end

  def edit
    @tag = Tag.find(params[:id])
  end

  def update
    @tag = Tag.find(params[:id])
    @tag.assign_attributes(tag_params)
    if @tag.save
      flash[:notice] = "#{@tag.name}を更新しました。"
      redirect_to(tag_path(@tag))
    else
      flash.now[:alert] = "入力に問題があります。エラー内容を確認してください。"
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy!
    flash[:notice] = "#{@tag.name}を削除しました。"
    redirect_to(tags_path)
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end
