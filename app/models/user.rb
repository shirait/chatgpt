class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :validatable, :timeoutable, :recoverable :registerable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable, :lockable
end
