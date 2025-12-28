class ChatsController < ApplicationController
  before_action :authenticate_user!

  def new
    authorize!(:new, MessageThread)
    @user_message = Message.new
    load_message_threads
  end

  def create
    authorize!(:create, MessageThread)
    @message_thread = MessageThread.build_message_thread(
      params: message_params,
      creator_id: current_user.id
    )
    @user_message = Message.build_user_message(
      params: message_params,
      message_thread: @message_thread,
      creator_id: current_user.id
    )

    if !(@user_message.save && @message_thread.save)
      flash.now[:alert] = @message_thread.errors.full_messages.join(", ") + @user_message.errors.full_messages.join(", ")
      load_message_threads
      render :new and return
    end

    begin
      GptMessageCreator.new(message_thread: @message_thread, user_message: @user_message).call!
      redirect_to chat_path(@message_thread) and return
    # 例外処理について、StandardError以外はrescueしないように注意（ https://github.com/shirait/blog_import_sample/issues/9#issuecomment-2142528418 ）
    rescue Faraday::Error => e
      flash.now[:alert] = faraday_error_message
    rescue StandardError => e
      flash.now[:alert] = unexpected_error_message
    end
    load_message_threads
    render :new
  end

  def show
    @message_thread = MessageThread.eager_load(:messages).order("messages.id").find(params[:id])
    authorize!(:read, @message_thread)
    load_message_threads
    @user_message = Message.new(message_thread_id: @message_thread.id)
  end

  def add_message
    @message_thread = MessageThread.find(params[:id])
    authorize!(:add_message, @message_thread)
    @user_message = Message.build_user_message(
      params: message_params,
      message_thread: @message_thread,
      creator_id: current_user.id
    )

    unless @user_message.save
      flash.now[:alert] = @user_message.errors.full_messages.join(", ")
      load_message_threads
      render :show and return
    end

    begin
      GptMessageCreator.new(message_thread: @message_thread, user_message: @user_message).call!
      redirect_to chat_path(@message_thread) and return
    rescue Faraday::Error => e
      flash.now[:alert] = faraday_error_message
    rescue StandardError => e
      flash.now[:alert] = unexpected_error_message
    end
    load_message_threads
    render :show
  end

  def edit
    @message_thread = MessageThread.find(params[:id])
    authorize!(:edit, @message_thread)
    load_message_threads
  end

  def update
    @message_thread = MessageThread.find(params[:id])
    authorize!(:update, @message_thread)

    @message_thread.assign_attributes(update_message_thread_params)
    if @message_thread.save
      flash[:notice] = "スレッドタイトルを更新しました。"
      redirect_to chat_path(@message_thread)
    else
      flash.now[:alert] = @message_thread.errors.full_messages.join(", ")
      load_message_threads
      render :edit and return
    end
  end

  def destroy
    @message_thread = MessageThread.find(params[:id])
    authorize!(:destroy, @message_thread)
    @message_thread.destroy!
    flash[:notice] = "スレッドを削除しました。"
    redirect_to root_path
  end

  private

  def load_message_threads
    @message_threads = MessageThread.accessible_by(current_ability).order(id: :asc)
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def update_message_thread_params
    params.require(:message_thread).permit(:title)
  end

  def faraday_error_message
    "OpenAI APIの利用でエラーが発生しました。繰り返し発生する場合はサーバ管理者に連絡してください。"
  end

  def unexpected_error_message
    "想定外のエラーが発生しました。繰り返し発生する場合はサーバ管理者に連絡してください。"
  end
end
