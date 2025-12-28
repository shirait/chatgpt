class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :validatable, :timeoutable, :recoverable :registerable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable, :lockable

  enum :role, { admin: 0, normal: 1 }

  has_many :message_threads, dependent: :destroy, foreign_key: :creator_id
  has_many :messages,        dependent: :destroy, foreign_key: :creator_id
  has_many :gpt_models,      dependent: :destroy, foreign_key: :creator_id

  validates :email, presence: true, uniqueness: true
  # on: :createはCRUD画面を作成したら追加する。
  validates :password, presence: true, length: { minimum: 6 }#, on: :create
  validates :password_confirmation, presence: true#, on: :create
  validates :role, presence: true, inclusion: { in: roles.keys }
end
