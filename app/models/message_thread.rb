class MessageThread < ApplicationRecord
  belongs_to :user, foreign_key: :creator_id
  has_many :messages, dependent: :destroy

  has_many :tag_message_threads, dependent: :destroy
  has_many :tags, through: :tag_message_threads

  validates :title, presence: true # 長さは Message#thread_title_length でチェックする。ちょっと変だけど。
  validates :creator_id, presence: true

  def self.build_message_thread(params:, creator_id:)
    new(
      title: params[:content].split("\n").select(&:present?).first.try(:chomp),
      creator_id: creator_id
    )
  end

  scope :content_like_search, ->(param) {
    return all if param.blank?

    left_joins(:messages).where("messages.content LIKE ?", "%#{param}%")
  }

  scope :tags_search, ->(tag_id) {
    return all if tag_id.blank?

    joins(:tags).where(tags: { id: tag_id })
  }

  scope :active_search, ->(active) {
    return all if active.blank?

    bool = (active.to_i == 1)
    where(active: bool)
  }
end
