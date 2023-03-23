class Comment < ApplicationRecord
  # has_many_attached :photos
  has_many_attached :files
  belongs_to :user_gig
  # validates :content, presence: true
end
