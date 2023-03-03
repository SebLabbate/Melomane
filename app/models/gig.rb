class Gig < ApplicationRecord
  belongs_to :user
  has_many_attached :photos

  validates :name, :date, :artist, :venue, presence: true
end
