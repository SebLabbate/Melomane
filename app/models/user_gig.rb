class UserGig < ApplicationRecord
  belongs_to :user
  belongs_to :gig
  accepts_nested_attributes_for :gig
  has_many_attached :photos
end
