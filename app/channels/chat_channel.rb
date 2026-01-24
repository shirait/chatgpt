class ChatChannel < ApplicationCable::Channel
  # コンシューマー（ブラウザ）がチャネルのサブスクライバになると、このコードが呼び出される。
  def subscribed
    message_thread = MessageThread.find(params[:message_thread_id])
    authorize!(:read, message_thread)

    # ブラウザにサブスクライブを実行。（引数がチャネル名になる）
    stream_from("chat_#{params[:message_thread_id]}")
  end

  # サーバー側で保持している状態や、一時的なデータ作成がある場合、破棄するコードを記述する。
  # 今回は特に必要ないので、何もしない。
  def unsubscribed
  end

  private

  def authorize!(action, resource)
    ability = Ability.new(current_user)
    raise CanCan::AccessDenied unless ability.can?(action, resource)
  end
end
