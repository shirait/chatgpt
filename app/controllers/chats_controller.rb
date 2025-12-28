class ChatsController < ApplicationController
  def index
  end

  def new
    @message_thread = MessageThread.new

    load_message_threads
  end

  def create
    @message = Message.new(message_params)
    @message_thread = MessageThread.new(title: @message.content.split("\n").select(&:present?).first)

    @message_thread.creator_id = 1 # current_user.id TODO: ログイン機能を追加したら修正する
    @message_thread.updater_id = 1 # current_user.id

    @message.message_thread = @message_thread
    @message.message_type = Message.message_types[:user]
    @message.creator_id = 1 # current_user.id TODO: ログイン機能を追加したら修正する
    @message.updater_id = 1 # current_user.id
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

      message = Message.new(
        message_thread_id: @message_thread.id,
        message_type: Message.message_types[:gpt],
        content: request_to_openai_api(@message),
        creator_id: 1, # current_user.id TODO: ログイン機能を追加したら修正する
        updater_id: 1 # current_user.id
      )
      message.save!
    end
    # TODO: エラーハンドリング
    redirect_to @message_thread
  end

  def show
    load_message_threads
    @message_thread = MessageThread.eager_load(:messages).order('messages.id').find(params[:id])
    @message = Message.new(message_thread_id: @message_thread.id)
  end

  def add_message
    # TODO: 認証・認可機能追加時にmessage_thread_idの権限チェック追加
    @message_thread = MessageThread.find(params[:id])
    @message = Message.new(add_message_params)
    @message.message_thread_id = @message_thread.id
    @message.message_type = Message.message_types[:user]
    @message.creator_id = 1 # current_user.id TODO: ログイン機能を追加したら修正する
    @message.updater_id = 1 # current_user.id

    if @message.invalid?
      flash.now[:alert] = @message.errors.full_messages.join(', ')
      load_message_threads
      render :show and return
    end

    ActiveRecord::Base.transaction do
      @message.save!

      message = Message.new(
        message_thread_id: @message_thread.id,
        message_type: Message.message_types[:gpt],
        content: request_to_openai_api(@message),
        creator_id: 1, # current_user.id TODO: ログイン機能を追加したら修正する
        updater_id: 1 # current_user.id
      )
      message.save!
    end

    redirect_to @message_thread
  end

  def edit
    load_message_threads
    @message_thread = MessageThread.find(params[:id])
  end

  def update
    # TODO: 認証・認可機能追加時にmessage_thread_idの権限チェック追加
    @message_thread = MessageThread.find(params[:id])
    @message_thread.assign_attributes(update_message_thread_params)
    @message_thread.save!
    # TODO: エラーハンドリング
    redirect_to @message_thread
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
        model: 'gpt-4.1-mini',
        messages: [{role: 'user', content: message.content}],
        temperature: 0.7,
      }
    )
    response.dig('choices', 0, 'message', 'content')
  end

  def message_params
    params.require(:message_thread).permit(:content)
  end

  def add_message_params
    params.require(:message).permit(:content)
  end

  def update_message_thread_params
    params.require(:message_thread).permit(:title)
  end
end
