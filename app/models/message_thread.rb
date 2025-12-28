class MessageThread < ApplicationRecord
  has_many :messages, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }
  validates :creator_id, presence: true
  validates :updater_id, presence: true
end
