require 'wikipedia'
require 'rspotify'
require 'uri'
require 'net/http'
require 'openssl'
require 'pexels'

class Gig < ApplicationRecord
  geocoded_by :venue
  after_validation :geocode, if:
   :will_save_change_to_venue?
  belongs_to :user
  has_many_attached :photos

 # validates :name, :artist, :date, :venue, presence: true
  before_create :parse_wiki_image, :spotify_genre, :spotify_images_artist, :spotify_images_albums, :pexel_photos
  before_create :parse_wiki_info, :spotify_top_five


  def parse_wiki_image
    if artist != nil
      page = Wikipedia.find(artist)
      photo = page.main_image_url
      if photo != nil
        self.wiki_photo_url = photo
      else
        self.wiki_photo_url = nil
      end
    else
      self.wiki_photo_url = nil
    end
  end

  def spotify_genre
    if artist != nil
      RSpotify::authenticate('13a5a78c35794c128471c373008efb01', '1cfa0c2e5bc04728b9e9e56731e0db20')
      artists = RSpotify::Artist.search(artist)
      artist = artists.first
      if artist.genres != nil
        genre = artist.genres
      else
        self.genre = nil
      end
      artist_genre = genre.sort_by { |item| item.length }
      first_artist_genre = artist_genre[0]
      if first_artist_genre != nil
        self.genre = first_artist_genre
      else
        self.genre = nil
      end
    else
      self.genre = nil
    end
  end

  def spotify_images_artist
    if artist != nil
      RSpotify::authenticate('13a5a78c35794c128471c373008efb01', '1cfa0c2e5bc04728b9e9e56731e0db20')
      artists = RSpotify::Artist.search(artist)
      artist = artists.first
      image = artist.images[0]
      photo_url = image.values[1]
      if photo_url != nil
        self.photo_url_two = photo_url
      else
        self.photo_url_two = nil
      end
    else
      self.photo_url_two = nil
    end
  end

  def spotify_images_albums
    if artist != nil
      RSpotify::authenticate('13a5a78c35794c128471c373008efb01', '1cfa0c2e5bc04728b9e9e56731e0db20')
      artists = RSpotify::Artist.search(artist)
      artist = artists.first
      albums = artist.albums[0]
      image = albums.images[0]
      photo_url = image.values[1]
      if photo_url != nil
        self.photo_url_three = photo_url
      else
        self.photo_url_three = nil
      end
    else
      self.photo_url_three = nil
    end
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
      if photo_url != nil
        self.photo_url_four = photo_url
      else
        self.photo_url_four = nil
      end
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
    if photo_url != nil
      self.photo_url_five = photo_url
    else
      self.photo_url_five= nil
    end
  end

  def parse_wiki_info
    if artist != nil
      page = Wikipedia.find(artist)
      if page.summary != nil
        info = "#{page.summary.split('.')[0]}.#{page.summary.split('.')[1]}."
      else
        info = nil
      end
      wiki_info = info
      if wiki_info != nil
        self.artist_info = wiki_info
      else
        self.artist_info = nil
      end
    else
      self.artist_info = nil
    end
  end

  def spotify_top_five
    if artist != nil
      RSpotify::authenticate('13a5a78c35794c128471c373008efb01', '1cfa0c2e5bc04728b9e9e56731e0db20')
      artists = RSpotify::Artist.search(artist)
      artist = artists.first
      top_songs = artist.top_tracks(:US)
      top_five = top_songs[0..5]
      if top_five[0] != nil
        self.song_one = top_five[0].name
      else
        self.song_one = nil
      end
      if top_five[1] != nil
        self.song_two = top_five[1].name
      else
        self.song_two = nil
      end
      if top_five[2] != nil
        self.song_three = top_five[2].name
      else
        self.song_three = nil
      end
    else
      self.song_one = nil
      self.song_two = nil
      self.song_three = nil
    end
  end


  def find_events_array_by_name(name)
    url = URI("https://app.ticketmaster.com/discovery/v2/events.json?apikey=dQnJo7HE3HCwNKc3HbpQvCF3ps9exT7y&keyword=#{name}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    response = http.request(request)
    events = response.read_body
    gigs = JSON.parse(events)
    if gigs["_embedded"] != nil
      events_hash = gigs["_embedded"]
      events_hash_two = events_hash["events"]
    else
      events_hash_two = nil
    end
    return events_hash_two
  end


  def find_event_image(event)
    artist_image = event["images"][1]["url"]
    return artist_image
  end

  def find_event_date
    event = find_events_array_by_name(@search_params)
    event_date = event["dates"]["start"]["dateTime"]
    date = event_date
    self.date = date
  end

  def find_event_venue
    event = find_events_array_by_name(@search_params)
    if event["_embedded"] != nil && event["_embedded"]["venues"] != nil
      event_venue = event["_embedded"]["venues"][0]["name"]
    else
      event_venue = nil
    end
    venue = event_venue
    self.venue = venue
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
