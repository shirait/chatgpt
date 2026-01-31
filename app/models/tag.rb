class Tag < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: :creator_id
  has_many :tag_message_threads, dependent: :destroy
  has_many :message_threads, through: :tag_message_threads

  validates :name, presence: true, length: { maximum: 255 }
  validates :creator_id, presence: true

  def self.build_tag(params, creator_id:)
    tag = new(params)
    tag.creator_id = creator_id
    tag
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id]
  end
end
