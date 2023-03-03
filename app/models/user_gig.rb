class UserGig < ApplicationRecord
  belongs_to :user
  belongs_to :gig
  has_many_attached :photos
end
