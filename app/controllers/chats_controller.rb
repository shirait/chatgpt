class ChatsController < ApplicationController
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

    if !@message_thread.valid? || !@user_message.valid?
      flash.now[:alert] = "入力に問題があります。エラー内容を確認してください。"
      load_message_threads_for_sidebar
      render(:new) and return
    end

    @message_thread.save && @user_message.save

    if use_http_call?
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
      render(:new)
    else
      # バックグラウンドジョブで非同期処理
      OpenAiChatJob.perform_later(@message_thread.id, @user_message.id)
      redirect_to chat_path(@message_thread)
    end
  end

  def use_http_call?
    Rails.configuration.static_config.use_http_call == true ||
    ENV["USE_HTTP_CALL"] == "true"
  end

  def show
    @message_thread = MessageThread.eager_load(messages: :message_files_attachments).order("messages.id").find(params[:id])
    authorize!(:read, @message_thread)
    load_message_threads_for_sidebar
    @user_message = Message.new(message_thread_id: @message_thread.id, send_prev_messages_to_openai_api: true)
  end

  def search
    authorize!(:search, MessageThread)
    @searched_message_threads = MessageThread.eager_load(:messages).accessible_by(current_ability).order("messages.id").where("messages.content LIKE ?", "%#{params[:search]}%")
    load_message_threads_for_sidebar
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
      render(:show) and return
    end

    if use_http_call?
      begin
        OpenAiChatCaller.new(message_thread: @message_thread, user_message: @user_message).call!
        flash[:notice] = "メッセージの送受信に成功しました。"
        redirect_to chat_path(@message_thread) and return
      rescue Faraday::Error => e
        flash.now[:alert] = t("common.faraday_error")
      rescue StandardError => e
        flash.now[:alert] = t("common.unexpected_error")
      end
      load_message_threads_for_sidebar
      render(:show)
    else
      # バックグラウンドジョブで非同期処理
      OpenAiChatJob.perform_later(@message_thread.id, @user_message.id)
      redirect_to chat_path(@message_thread)
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

  private

  def load_message_threads_for_sidebar
    @message_threads_for_sidebar = MessageThread.accessible_by(current_ability).order(id: :asc)
  end

  def message_params
    params.require(:message).permit(:content, :send_prev_messages_to_openai_api, message_files: [])
  end

  def update_message_thread_params
    params.require(:message_thread).permit(:title)
  end
end
