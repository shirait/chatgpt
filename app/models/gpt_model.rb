class GptModel < ApplicationRecord
  belongs_to :user, foreign_key: :creator_id
  has_many :messages, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 255 }
  validates :creator_id, presence: true

  def self.active_model
    # todo: CRUD画面を作成したら動的に取得できるようにする。
    self.find(1)
  end
end
