class ChatsController < ApplicationController
  def new
    @user_message = Message.new
    load_message_threads
  end

  def create
    @message_thread = MessageThread.new(
      title: Message.new(message_params).content.split("\n").select(&:present?).first,
      creator_id: 1 # current_user.id TODO: ログイン機能を追加したら修正する
    )
    @user_message = prepare_user_message(@message_thread)

    if !(@user_message.save && @message_thread.save)
      flash.now[:alert] = @message_thread.errors.full_messages.join(', ') + @user_message.errors.full_messages.join(', ')
      load_message_threads
      render :new and return
    end

    begin
      create_gpt_message!(@message_thread, @user_message)
    rescue => e
      flash.now[:alert] = '想定外のエラーが発生しました。繰り返し発生する場合はサーバ管理者に連絡してください。'
      load_message_threads
      render :new and return
    end
    redirect_to chat_path(@message_thread)
  end

  def show
    load_message_threads
    @message_thread = MessageThread.eager_load(:messages).order('messages.id').find(params[:id])
    @user_message = Message.new(message_thread_id: @message_thread.id)
  end

  def add_message
    # TODO: 認証・認可機能追加時にmessage_thread_idの権限チェック追加
    @message_thread = MessageThread.find(params[:id])
    @user_message = prepare_user_message(@message_thread)

    unless @user_message.save
      flash.now[:alert] = @user_message.errors.full_messages.join(', ')
      load_message_threads
      render :show and return
    end

    begin
      create_gpt_message!(@message_thread, @user_message)
    rescue => e
      flash.now[:alert] = '想定外のエラーが発生しました。繰り返し発生する場合はサーバ管理者に連絡してください。'
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
  def create_gpt_message!(message_thread, user_message)
    Message.create!(
      message_thread_id: message_thread.id,
      gpt_model_id: user_message.gpt_model.id,
      message_type: Message.message_types[:gpt],
      content: request_to_openai_api(user_message),
      creator_id: 1, # current_user.id TODO: ログイン機能を追加したら修正する
    )
  end

  def prepare_user_message(message_thread)
    user_message = Message.new(message_params)
    user_message.message_thread = message_thread
    user_message.message_type = Message.message_types[:user]
    user_message.creator_id = 1 # current_user.id TODO: ログイン機能を追加したら修正する
    user_message.gpt_model = GptModel.active_model
    user_message
  end
end
