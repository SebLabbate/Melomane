class Gig < ApplicationRecord
  belongs_to :user
  has_many_attached :photos

  validates :name, :date, :artist, :venue, presence: true

  before_create :parse_wiki_image

  def parse_wiki_image
    page = Wikipedia.find(artist)
    photo = page.main_image_url
    self.wiki_photo_url = photo
  end


end
