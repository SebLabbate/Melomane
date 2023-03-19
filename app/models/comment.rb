class Comment < ApplicationRecord
  has_many_attached :photos
  belongs_to :user_gig
  # validates :content, presence: true
end
