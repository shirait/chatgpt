class TalkMessage < ApplicationRecord
  belongs_to :talk_thread
  belongs_to :sender, class_name: "User"

  validates :content, presence: true
  validates :sender_id, presence: true
  validates :talk_thread_id, presence: true
end
