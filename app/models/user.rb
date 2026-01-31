class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :validatable, :timeoutable, :recoverable :registerable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable, :lockable

  enum :role, { admin: 0, normal: 1 }

  # 管理者のリレーション
  has_many :created_users, class_name: "User", foreign_key: :creator_id, dependent: :restrict_with_error
  has_many :updated_users, class_name: "User", foreign_key: :updater_id, dependent: :restrict_with_error
  has_many :gpt_models,    foreign_key: :creator_id, dependent: :restrict_with_error

  # 一般ユーザーのリレーション
  has_many :message_threads, foreign_key: :creator_id, dependent: :destroy
  has_many :messages,        foreign_key: :creator_id, dependent: :destroy

  # 管理者、一般ユーザーに共通のリレーション
  belongs_to :creator, class_name: "User", foreign_key: :creator_id
  belongs_to :updater, class_name: "User", foreign_key: :updater_id

  validates :name, presence: true, length: { maximum: 255 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 255 }
  validates :password, presence: true, length: { minimum: 6, maximum: 128 }, confirmation: true, if: :password_validation_required?
  validates :password_confirmation, presence: true, length: { minimum: 6, maximum: 128 }, if: :password_validation_required?
  validates :role, presence: true, inclusion: { in: roles.keys }
  validates :active, inclusion: { in: [ true, false ] }, allow_blank: true
  validates :creator_id, presence: true
  validates :updater_id, presence: true

  def self.build_user(params, creator_id:)
    user = new(params)
    user.creator_id = creator_id
    user.updater_id = creator_id
    user
  end

  def assign_update_attributes(params, updater_id:)
    assign_attributes(params)
    self.updater_id = updater_id

    if password.blank?
      self.password = nil
      self.password_confirmation = nil
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name email role active]
  end

  private

  def password_validation_required?
    new_record? || password.present?
  end
end
