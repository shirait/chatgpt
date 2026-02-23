class ChatsController < ApplicationController
  include ConfigResponseType
  # メインで扱うモデル名が Chat ではないので load_and_authorize_resource を使用しない。
  # 権限チェックは各アクションで authorize! を実行すること。

  def new
    authorize!(:new, MessageThread)
    @user_message = Message.new(send_prev_messages_to_openai_api: true)
    load_message_threads_for_sidebar
  end

  def create
    authorize!(:create, MessageThread)

    prepare_message_thread_and_user_message_for_create

    if !message_thread_and_user_message_valid?
      set_flash_message_for_unprocessable_entity
      render(:new, status: :unprocessable_entity) and return
    end

    @message_thread.save! && @user_message.save!

    call_openai_api(:new)
  end

  def show
    @message_thread = MessageThread.eager_load(messages: :message_files_attachments).order("messages.id").find(params[:id])
    authorize!(:read, @message_thread)
    load_message_threads_for_sidebar
    @user_message = Message.new(message_thread_id: @message_thread.id, gpt_model: GptModel.active_gpt_model)
  end

  def search
    authorize!(:search, MessageThread)
    load_message_threads_for_sidebar

    @tags_for_search = Tag.accessible_by(current_ability).order(id: :asc).pluck(:name, :id)

    params[:q] ||= { active_eq: "1" }
    # タグは preload にすること。
    # eager_load だと tags_id_eq の JOIN 条件で指定タグのみが読み込まれる
    # （タグA、タグB、タグCが紐づいたスレッドをタグAで検索すると、画面にタグB、タグCが表示されない）
    @q = MessageThread.eager_load(:messages).accessible_by(current_ability).ransack(params[:q])
    @searched_message_threads = @q.result(distinct: true).preload(:tags)
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
      set_flash_message_for_unprocessable_entity
      render(:show, status: :unprocessable_entity) and return
    end

    call_openai_api(:show)
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
      set_flash_message_for_unprocessable_entity
      render(:edit, status: :unprocessable_entity) and return
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
      OpenAiChatCallerHttp.new(message_thread: @message_thread, user_message: @user_message).call!
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

  def call_openai_api(render_path)
    if response_type_http?
      call_openai_api_with_http(render_path)
    elsif response_type_websocket?
      call_openai_api_with_websocket
    end
  end

  def prepare_message_thread_and_user_message_for_create
    @message_thread = MessageThread.build_message_thread(
      params: message_params,
      creator_id: current_user.id
    )
    @user_message = Message.build_user_message(
      params: message_params,
      message_thread: @message_thread,
      creator_id: current_user.id
    )
  end

  def message_thread_and_user_message_valid?
    @message_thread.valid?
    @user_message.valid?
    @message_thread.errors.none? && @user_message.errors.none?
  end

  def set_flash_message_for_unprocessable_entity
    flash.now[:alert] = "入力に問題があります。エラー内容を確認してください。"
    load_message_threads_for_sidebar
  end
end
