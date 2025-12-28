class MessageThread < ApplicationRecord
  has_many :messages, dependent: :destroy

  # todo: バリデーション追加
end
