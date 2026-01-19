class TagMessageThread < ApplicationRecord
  belongs_to :tag,            optional: false
  belongs_to :message_thread, optional: false

  validates :tag_id,            presence: true
  validates :message_thread_id, presence: true
end