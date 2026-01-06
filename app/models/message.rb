class Message < ApplicationRecord
  belongs_to :user, foreign_key: :creator_id
  belongs_to :gpt_model
  belongs_to :message_thread
  has_many_attached :message_files, dependent: :destroy

  enum :message_type, { user: 0, assistant: 1 } # user: ユーザーからのメッセージ, assistant: GPTからのメッセージ

  attr_accessor :send_prev_messages_to_openai_api

  validates :message_type, presence: true, inclusion: { in: message_types.keys }
  validates :gpt_model, presence: true
  validates :message_thread, presence: true
  validates :content, presence: true # text型なのでlengthは指定しない。トークン数が増えすぎるようであれば別途指定を検討する。
  validates :creator_id, presence: true
  validate  :thread_title_length

  def self.build_user_message(params:, message_thread:, creator_id:)
    message = new(
      content: params[:content],
      message_thread: message_thread,
      message_type: :user,
      creator_id: creator_id,
      gpt_model: GptModel.active_gpt_model,
      send_prev_messages_to_openai_api: params[:send_prev_messages_to_openai_api] == "1"
    )

    if params[:message_files].present?
      message.message_files.attach(params[:message_files])
    end

    message
  end

  def send_prev_messages_to_openai_api?
    !!send_prev_messages_to_openai_api
  end

  scope :prev_messages, ->(message, limit) {
    where(message_thread_id: message.message_thread.id)
      .where.not(id: message.id)
      .order(id: :desc)
      .limit(limit)
  }

  private

  def thread_title_length
    return if persisted?
    thread_title = message_thread.title
    return if thread_title.blank?

    if thread_title.length > 255
      errors.add(:content, "の最初の行はタイトルとして登録します。タイトルは255文字以内にしてください。")
    end
  end
end
