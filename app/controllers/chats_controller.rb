class ChatsController < ApplicationController
  include ConfigSwitches
  # メインで扱うモデル名が Chat ではないので load_and_authorize_resource を使用しない。
  # 権限チェックは各アクションで authorize! を実行すること。

  def new
    authorize!(:new, MessageThread)
    @user_message = Message.new(send_prev_messages_to_openai_api: true)
    load_message_threads_for_sidebar
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
    raise "test exception"

    if !@message_thread.valid? || !@user_message.valid?
      flash.now[:alert] = "入力に問題があります。エラー内容を確認してください。"
      load_message_threads_for_sidebar
      render(:new, status: :unprocessable_entity) and return
    end

    @message_thread.save && @user_message.save

    if use_http_call?
      call_openai_api_with_http(:new)
    elsif use_websocket?
      call_openai_api_with_websocket
    end
  end

  def show
    @message_thread = MessageThread.eager_load(messages: :message_files_attachments).order("messages.id").find(params[:id])
    authorize!(:read, @message_thread)
    load_message_threads_for_sidebar
    @user_message = Message.new(message_thread_id: @message_thread.id, send_prev_messages_to_openai_api: true)
  end

  def search
    authorize!(:search, MessageThread)
    load_message_threads_for_sidebar

    @tags_for_search = Tag.accessible_by(current_ability).order(name: :asc)
    @searched_message_threads = MessageThread.
      eager_load(:tags).
      accessible_by(current_ability).
      content_like_search(params[:search]).
      tags_search(params[:tag_id]).
      active_search(params[:active] || 1).
      order(id: :asc)
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
      flash.now[:alert] = "入力に問題があります。エラー内容を確認してください。"
      load_message_threads_for_sidebar
      render(:show, status: :unprocessable_entity) and return
    end

    if use_http_call?
      call_openai_api_with_http(:show)
    elsif use_websocket?
      call_openai_api_with_websocket
    end
  end

  def edit
    @message_thread = MessageThread.find(params[:id])
    authorize!(:edit, @message_thread)
    load_message_threads_for_sidebar
  end

  def update
    @message_thread = MessageThread.find(params[:id])
    authorize!(:update, @message_thread)

    @message_thread.assign_attributes(update_message_thread_params)
    if @message_thread.save
      flash[:notice] = "タイトルを更新しました。"
      redirect_to(chat_path(@message_thread))
    else
      flash.now[:alert] = "入力に問題があります。エラー内容を確認してください。"
      load_message_threads_for_sidebar
      render(:edit) and return
    end
  end

  def destroy
    @message_thread = MessageThread.find(params[:id])
    authorize!(:destroy, @message_thread)
    @message_thread.destroy!
    flash[:notice] = "削除しました。"
    redirect_to(root_path)
  end

  def hide
    @message_thread = MessageThread.find(params[:id])
    authorize!(:hide, @message_thread)
    @message_thread.update!(active: false)
    flash[:notice] = "非表示にしました。"
    redirect_to(chat_path(@message_thread))
  end

  def open
    @message_thread = MessageThread.find(params[:id])
    authorize!(:open, @message_thread)
    @message_thread.update!(active: true)
    flash[:notice] = "表示にしました。"
    redirect_to(chat_path(@message_thread))
  end

  def edit_tag_message_thread
    @message_thread = MessageThread.eager_load(:tags).find(params[:id])
    authorize!(:link_tag, @message_thread)
    @tags = Tag.accessible_by(current_ability).order(id: :asc)
    load_message_threads_for_sidebar
  end

  def update_tag_message_thread
    @message_thread = MessageThread.find(params[:id])
    authorize!(:link_tag, @message_thread)

    @link_tags = Tag.accessible_by(current_ability).where(id: params[:message_thread][:tag_ids])
    @message_thread.tag_ids = @link_tags.pluck(:id)
    flash[:notice] = "タグを更新しました。"
    redirect_to(chat_path(@message_thread))
  end

  private

  def load_message_threads_for_sidebar
    @message_threads_for_sidebar = MessageThread.preload(:tags).accessible_by(current_ability).where(active: true).order(id: :asc)
  end

  def message_params
    params.require(:message).permit(:content, :send_prev_messages_to_openai_api, message_files: [])
  end

  def update_message_thread_params
    params.require(:message_thread).permit(:title)
  end

  def call_openai_api_with_http(render_path)
    begin
      OpenAiChatCaller.new(message_thread: @message_thread, user_message: @user_message).call!
      flash[:notice] = "メッセージの送受信に成功しました。"
      redirect_to chat_path(@message_thread) and return
    # 例外処理について、StandardError以外はrescueしないように注意（ https://github.com/shirait/blog_import_sample/issues/9#issuecomment-2142528418 ）
    rescue Faraday::Error => e
      flash.now[:alert] = t("common.faraday_error")
    rescue StandardError => e
      flash.now[:alert] = t("common.unexpected_error")
    end
    load_message_threads_for_sidebar
    render(render_path, status: :unprocessable_entity)
  end

  def call_openai_api_with_websocket
    # バックグラウンドジョブで非同期処理
    OpenAiChatJob.perform_later(
      @message_thread.id,
      @user_message.id,
      @user_message.send_prev_messages_to_openai_api?
    )
    redirect_to chat_path(@message_thread)
  end
end
