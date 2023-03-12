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

  include PgSearch::Model
  pg_search_scope :search_by_artist_and_venue,
    against: [ :artist, :venue ],
    using: {
      tsearch: { prefix: true }
    }
  # include PgSearch::Model
  # multisearchable against: [ :artist, :venue ]
end
