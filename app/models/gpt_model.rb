class GptModel < ApplicationRecord
  has_many :messages, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 255 }
  validates :creator_id, presence: true
end
