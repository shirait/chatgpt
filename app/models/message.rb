class Message < ApplicationRecord
  belongs_to :gpt_model
  belongs_to :message_thread

  enum :message_type, { user: 0, gpt: 1 } # user: ユーザーからのメッセージ, gpt: GPTからのメッセージ

  validates :message_type, presence: true, inclusion: { in: message_types.keys }
  validates :content, presence: true # text型なのでlengthは指定しない。トークン数が増えすぎるようであれば別途指定を検討する。
  validates :creator_id, presence: true
  validates :updater_id, presence: true
end
