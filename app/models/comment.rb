class Comment < ApplicationRecord
  belongs_to :user_gig
  # validates :content, presence: true
end
