class TagsController < ApplicationController
  load_and_authorize_resource

  def index
    @tags = Tag.all
    # review: ここでメッセージスレッドの一覧を取得する必要があるか？
    load_message_threads_for_sidebar
  end

  def new
    @tag = Tag.new
    load_message_threads_for_sidebar
  end

  def create
    @tag = Tag.build_tag(tag_params, creator_id: current_user.id)
    if @tag.save
      flash[:notice] = "#{@tag.name}を作成しました。"
      redirect_to(tag_path(@tag))
    else
      flash.now[:alert] = "入力に問題があります。エラー内容を確認してください。"
      load_message_threads_for_sidebar
      render(:new, status: :unprocessable_entity)
    end
  end

  def show
    load_message_threads_for_sidebar
    @tag = Tag.find(params[:id])
  end

  def edit
    load_message_threads_for_sidebar
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
      load_message_threads_for_sidebar
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

  def load_message_threads_for_sidebar
    @message_threads_for_sidebar = MessageThread.accessible_by(current_ability).where(active: true).order(id: :asc)
  end
end
