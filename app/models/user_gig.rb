class UserGig < ApplicationRecord
  has_many_attached :photos
  belongs_to :user
  belongs_to :gig
  accepts_nested_attributes_for :gig
  has_many :comments, dependent: :destroy
end
