class MessageThread < ApplicationRecord
  has_many :messages, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }
  validates :creator_id, presence: true

  def self.build_message_thread(params:, creator_id:)
    new(
      title: params[:content].split("\n").select(&:present?).first,
      creator_id: creator_id
    )
  end
end
