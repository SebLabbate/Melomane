class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :gigs
  has_many :user_gigs
  has_many_attached :photos

  validates :user_name, :password, :email, presence: true
  validates :email, uniqueness: true
  validates :password, length: { minimum: 6 }
end
