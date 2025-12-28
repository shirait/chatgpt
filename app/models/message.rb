class Message < ApplicationRecord
  belongs_to :message_thread
  enum :message_type, { user: 0, gpt: 1 } # user: ユーザーからのメッセージ, gpt: GPTからのメッセージ

  # todo: バリデーション追加
end
