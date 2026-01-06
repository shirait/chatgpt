class MessageThread < ApplicationRecord
  belongs_to :user, foreign_key: :creator_id
  has_many :messages, dependent: :destroy

  validates :title, presence: true # 長さは Message#thread_title_length でチェックする。ちょっと変だけど。
  validates :creator_id, presence: true

  def self.build_message_thread(params:, creator_id:)
    new(
      title: params[:content].split("\n").select(&:present?).first.chomp,
      creator_id: creator_id
    )
  end
end
