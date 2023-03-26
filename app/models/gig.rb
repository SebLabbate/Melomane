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

  validates :artist, :date, :venue, presence: true
  before_create :parse_wiki_image, :spotify_genre, :spotify_images_artist, :spotify_images_albums, :pexel_photos
  before_create :parse_wiki_info, :spotify_top_five

  def parse_wiki_image
    page = Wikipedia.find(artist)
    photo = page.main_image_url
    if photo != nil
      self.wiki_photo_url = photo
    else
      self.wiki_photo_url = nil
    end
  end

  def spotify_genre
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
  end

  def spotify_images_artist
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
  end

  def spotify_images_albums
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
  end

  def spotify_top_five
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
  end


  def get_track_id(artist_first_name, artist_last_name, song_name)
    url = URI("https://soundcloud-scraper.p.rapidapi.com/v1/search/tracks?term=#{artist_first_name}%20#{artist_last_name}%20#{song_name}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = 'bb141578ecmsh6d28efe29ac7316p11e81cjsn2a1ed1dbaddf'
    request["X-RapidAPI-Host"] = 'soundcloud-scraper.p.rapidapi.com'
    response = http.request(request)
    string = response.read_body
    track_id_with_extras = string.split('"')[16]
    if track_id_with_extras != nil
      track_id_incomplete = track_id_with_extras.split(':')
      track_id = track_id_incomplete[1].split(',')
      track_id_two = track_id[0]
      return track_id_two
    else
      return nil
    end
  end

  def get_track_url(track_id)
    url = URI("https://soundcloud-scraper.p.rapidapi.com/v1/track/metadata?track=#{track_id}&download=sq")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Key"] = 'bb141578ecmsh6d28efe29ac7316p11e81cjsn2a1ed1dbaddf'
    request["X-RapidAPI-Host"] = 'soundcloud-scraper.p.rapidapi.com'
    response = http.request(request)
    body = response.read_body
    track_url = body.split('"')[11]
    return track_url
  end

  def split_artist_first_name(name)
    split_name = name.split(" ")
    if split_name.length == 2
      first_name = split_name[0].downcase
    else
      first_name = name.downcase
    end
    return first_name
  end

  def split_artist_last_name(name)
    split_name = name.split(" ")
    if split_name.length == 2
      last_name = split_name[1].downcase
    else
      last_name = nil
    end
    return last_name
  end

  def return_audio(track_name)
    first_name = split_artist_first_name(artist)
    last_name = split_artist_last_name(artist)
    track_id = get_track_id(first_name, last_name, track_name)
    track_url = get_track_url(track_id)
    return track_url
  end

  def return_audio_one
    first_name = split_artist_first_name(artist)
    last_name = split_artist_last_name(artist)
    track_id = get_track_id(first_name, last_name, song_one)
    track_url = get_track_url(track_id)
    url = track_url
    if url != nil
      self.song_one_audio = url
    else
      self.song_one_audio = nil
    end
  end

  def return_audio_two
    first_name = split_artist_first_name(artist)
    last_name = split_artist_last_name(artist)
    track_id = get_track_id(first_name, last_name, song_two)
    track_url = get_track_url(track_id)
    url = track_url
    if url != nil
      self.song_two_audio = url
    else
      self.song_two_audio = nil
    end
  end

  def return_audio_three
    first_name = split_artist_first_name(artist)
    last_name = split_artist_last_name(artist)
    track_id = get_track_id(first_name, last_name, song_three)
    track_url = get_track_url(track_id)
    url = track_url
    if url != nil
      self.song_three_audio = url
    else
      self.song_three_audio = nil
    end
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
