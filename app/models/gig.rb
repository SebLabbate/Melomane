require 'wikipedia'
require 'rspotify'
require 'uri'
require 'net/http'
require 'openssl'
require 'pexels'

class Gig < ApplicationRecord
  belongs_to :user
  has_many_attached :photos

  validates :name, :date, :artist, :venue, presence: true

  before_create :parse_wiki_image, :spotify_genre, :spotify_images_artist, :spotify_images_albums, :pexel_photos, :pexel_photos_two

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

  def spotify_images_artist
    RSpotify::authenticate('13a5a78c35794c128471c373008efb01', '1cfa0c2e5bc04728b9e9e56731e0db20')
    artists = RSpotify::Artist.search(artist)
    artist = artists.first
    image = artist.images[0]
    photo_url = image.values[1]
    self.photo_url_two = photo_url
  end

  def spotify_images_albums
    RSpotify::authenticate('13a5a78c35794c128471c373008efb01', '1cfa0c2e5bc04728b9e9e56731e0db20')
    artists = RSpotify::Artist.search(artist)
    artist = artists.first
    albums = artist.albums[0]
    image = albums.images[0]
    photo_url = image.values[1]
    self.photo_url_three = photo_url
  end

  def pexel_photos
    client = Pexels::Client.new('41EOfTlvkrnn8r297MvVFXPjmYq2jLs9OGSGZLfrQpDRmFVXMvMJdCHO')
    photo = client.photos.search('concert').to_a
    first = photo[rand(1..12)].src
    array = []
    first.each_value do |value|
      array << value
    end
    photo_url = array[0]
    self.photo_url_four = photo_url
  end

  def pexel_photos_two
    client = Pexels::Client.new('41EOfTlvkrnn8r297MvVFXPjmYq2jLs9OGSGZLfrQpDRmFVXMvMJdCHO')
    photo = client.photos.search('concert').to_a
    first = photo[rand(1..12)].src
    array = []
    first.each_value do |value|
      array << value
    end
    photo_url = array[0]
    self.photo_url_five = photo_url
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
