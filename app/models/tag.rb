class Tag < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: :creator_id

  validates :name, presence: true, length: { maximum: 255 }
  validates :creator_id, presence: true

  def self.build_tag(params, creator_id:)
    tag = new(params)
    tag.creator_id = creator_id
    tag
  end
end
