class MessageThreadsController < ApplicationController
  def index
  end

  def new
    @message_thread = MessageThread.new
  end

  def create
    @message_thread = MessageThread.new(message_thread_params)
    @message_thread.creator_id = 1 # current_user.id TODO: ログイン機能を追加したら修正する
    @message_thread.updater_id = 1 # current_user.id

    ActiveRecord::Base.transaction do
      @message_thread.save!
      @message = Message.new(message_params)
      @message.message_thread_id = @message_thread.id
      @message.message_type = Message.message_types[:user]
      @message.creator_id = 1 # current_user.id TODO: ログイン機能を追加したら修正する
      @message.updater_id = 1 # current_user.id
      @message.save!
    end
    redirect_to @message_thread
  end

  def show
    @message_thread = MessageThread.find(params[:id])
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
    @message.save!

    redirect_to @message_thread
  end

  def edit
    @message_thread = MessageThread.find(params[:id])
  end

  def update
  end

  def destroy
  end

  private

  def message_thread_params
    params.require(:message_thread).permit(:title)
  end

  def message_params
    params.require(:message_thread).permit(:content)
  end

  def add_message_params
    params.require(:message).permit(:content)
  end
end
