class TalkThread < ApplicationRecord
  belongs_to :user
  has_many :talk_messages, dependent: :destroy

  validates :user_id, presence: true
end
