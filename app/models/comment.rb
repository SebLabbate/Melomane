class Comment < ApplicationRecord
  belongs_to :user_gig
  validates :comment, presence: true
end
