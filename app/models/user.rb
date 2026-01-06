class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :validatable, :timeoutable, :recoverable :registerable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable, :lockable

  enum :role, { admin: 0, normal: 1 }

  # 管理者のリレーション
  has_many :created_users, class_name: "User", foreign_key: :creator_id, dependent: :restrict_with_error
  has_many :updated_users, class_name: "User", foreign_key: :updater_id, dependent: :restrict_with_error
  has_many :gpt_models,      dependent: :destroy, foreign_key: :creator_id, dependent: :restrict_with_error

  # 一般ユーザーのリレーション
  has_many :message_threads, dependent: :destroy, foreign_key: :creator_id, dependent: :destroy
  has_many :messages,        dependent: :destroy, foreign_key: :creator_id, dependent: :destroy

  # 共通のリレーション
  belongs_to :creator, class_name: "User", foreign_key: :creator_id
  belongs_to :updater, class_name: "User", foreign_key: :updater_id

  validates :name, presence: true, length: { maximum: 255 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 255 }
  validates :password, presence: true, length: { minimum: 6, maximum: 128 }, on: :create
  validates :password_confirmation, presence: true, length: { minimum: 6, maximum: 128 }, on: :create
  validates :role, presence: true, inclusion: { in: roles.keys }
  validates :active, inclusion: { in: [true, false] }, allow_blank: true
  validates :creator_id, presence: true
  validates :updater_id, presence: true
end
