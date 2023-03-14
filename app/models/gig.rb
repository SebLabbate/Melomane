class Gig < ApplicationRecord
  belongs_to :user
  has_many_attached :photos

  validates :name, :date, :artist, :venue, presence: true

  before_create :parse_wiki_image, :spotify_genre

  def parse_wiki_image
    page = Wikipedia.find(artist)
    photo = page.main_image_url
    self.wiki_photo_url = photo
  end

  def spotify_genre
    RSpotify::authenticate('13a5a78c35794c128471c373008efb01', '1cfa0c2e5bc04728b9e9e56731e0db20')
    artists = RSpotify::Artist.search(artist)
    artist = artists.first
    genre = artist.genres
    artist_genre = genre.sort_by { |item| item.length }
    first_artist_genre = artist_genre[0]
    self.genre = first_artist_genre
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
