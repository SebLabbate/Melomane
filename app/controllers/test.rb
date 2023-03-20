require 'wikipedia'
require 'rspotify'
require 'uri'
require 'net/http'
require 'openssl'
require 'pexels'

def return_audio(track_name)
  first_name = split_artist_first_name(@user_gig.gig.artist)
  last_name = split_artist_last_name(@user_gig.gig.artist)
  track_id = get_track_id(first_name, last_name, track_name)
  track_url = get_track_url(track_id)
  return track_url
end

def return_audio_array
  array = []
  @spotify_top_songs.each do |track|
    array << return_audio(track.name)
  end
  return array
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
    track_id_with_extras = string.split('"')[16]
    track_id_incomplete = track_id_with_extras.split(':')
    track_id = track_id_incomplete[1].split(',')
    track_id_two = track_id[0]
    return track_id_two
  else
    return nil
  end
end

artist_first_name = "Edewfew"
artist_last_name = "Sheerfewwfean"
song_name = "Photogrwefewaph"

song = get_track_id(artist_first_name, artist_last_name, song_name)
puts song
