class GptModel < ApplicationRecord
  belongs_to :user, foreign_key: :creator_id
  has_many :messages, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 255 }
  validates :creator_id, presence: true

  def self.active_gpt_model
    where(active: true).first
  end

  def self.build_gpt_model(params, creator_id:)
    gpt_model = new(params)
    gpt_model.creator_id = creator_id
    gpt_model
  end
end
