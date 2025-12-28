class ChatsController < ApplicationController
  def new
    @message = Message.new
    load_message_threads
  end

  def create
    @message = Message.new(message_params)
    @message_thread = MessageThread.new(
      title: @message.content.split("\n").select(&:present?).first,
      creator_id: 1 # current_user.id TODO: ログイン機能を追加したら修正する
    )

    @message.message_thread = @message_thread
    @message.message_type = Message.message_types[:user]
    @message.creator_id = 1 # current_user.id TODO: ログイン機能を追加したら修正する
    @message.gpt_model = GptModel.active_model
    if @message.invalid?
      flash.now[:alert] = @message.errors.full_messages.join(', ')
      load_message_threads
      render :new and return
    end

    if @message_thread.invalid?
      flash.now[:alert] = @message_thread.errors.full_messages.join(', ')
      load_message_threads
      render :new and return
    end

    ActiveRecord::Base.transaction do
      @message_thread.save!
      @message.save!
      create_response_message!(@message_thread, @message)
    rescue ActiveRecord::RecordInvalid => e
      # DB保存エラー。基本的には発生しない想定。
      flash.now[:alert] = 'チャットのDBへの保存に失敗しました。'
      # ロールバックは行わない
      load_message_threads
      render :new and return
    rescue => e
      # 未知のエラー。openai apiとの疎通に失敗した場合などに発生する想定。
      flash.now[:alert] = '想定外のエラーが発生しました。繰り返し発生する場合はサーバ管理者に連絡してください。'
      # ロールバックは行わない
      load_message_threads
      render :new and return
    end
    redirect_to chat_path(@message_thread)
  end

  def show
    load_message_threads
    @message_thread = MessageThread.eager_load(:messages).order('messages.id').find(params[:id])
    @message = Message.new(message_thread_id: @message_thread.id)
  end

  def add_message
    # TODO: 認証・認可機能追加時にmessage_thread_idの権限チェック追加
    @message_thread = MessageThread.find(params[:id])
    @message = Message.new(message_params)
    @message.message_thread_id = @message_thread.id
    @message.message_type = Message.message_types[:user]
    @message.creator_id = 1 # current_user.id TODO: ログイン機能を追加したら修正する
    @message.gpt_model = GptModel.active_model

    if @message.invalid?
      flash.now[:alert] = @message.errors.full_messages.join(', ')
      load_message_threads
      render :show and return
    end

    ActiveRecord::Base.transaction do
      @message.save!
      create_response_message!(@message_thread, @message)
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = 'チャットのDBへの保存に失敗しました。'
      # ロールバックは行わない
      load_message_threads
      render :show and return
    rescue => e
      flash.now[:alert] = '想定外のエラーが発生しました。繰り返し発生する場合はサーバ管理者に連絡してください。'
      # ロールバックは行わない
      load_message_threads
      render :show and return
    end

    redirect_to chat_path(@message_thread)
  end

  def edit
    load_message_threads
    @message_thread = MessageThread.find(params[:id])
  end

  def update
    # TODO: 認証・認可機能追加時にmessage_thread_idの権限チェック追加
    @message_thread = MessageThread.find(params[:id])
    @message_thread.assign_attributes(update_message_thread_params)

    if @message_thread.save
      flash[:notice] = 'スレッドタイトルを更新しました。'
      redirect_to chat_path(@message_thread)
    else
      flash.now[:alert] = @message_thread.errors.full_messages.join(', ')
      load_message_threads
      render :edit and return
    end
  end

  def destroy
    # TODO: 認証・認可機能追加時にmessage_thread_idの権限チェック追加
    @message_thread = MessageThread.find(params[:id])
    @message_thread.destroy!
    # TODO: エラーハンドリング
    redirect_to root_path
  end

  private

  def load_message_threads
    # todo: ログイン機能を追加したら修正する
    @message_threads = MessageThread.where(creator_id: 1).order(id: :asc)
  end

  # review: ここに書くべきロジックではないかもしれない。
  def request_to_openai_api(message)
    access_token = Rails.configuration.static_config.openai_key
    client = OpenAI::Client.new(access_token: access_token)
    response = client.chat(
      parameters: {
        model: message.gpt_model.name,
        messages: [{role: 'user', content: message.content}],
        temperature: 0.7,
      }
    )
    response.dig('choices', 0, 'message', 'content')
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def update_message_thread_params
    params.require(:message_thread).permit(:title)
  end

  # review: ここに書くべきロジックではないかもしれない。
  def create_response_message!(message_thread, message)
    message = Message.create!(
      message_thread_id: message_thread.id,
      gpt_model_id: message.gpt_model.id,
      message_type: Message.message_types[:gpt],
      content: request_to_openai_api(message),
      creator_id: 1, # current_user.id TODO: ログイン機能を追加したら修正する
    )
  end
end
