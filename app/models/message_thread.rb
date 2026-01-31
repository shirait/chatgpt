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

  def self.ransackable_attributes(auth_object = nil)
    %w[active]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[tags messages]
  end
end
