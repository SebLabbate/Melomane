require 'uri'
require 'net/http'
require 'openssl'


#find track ID

artist_first_name = "Post"
artist_last_name = "Malone"
song_name = "rockstar (feat. 21 Savage)"

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
track_id_incomplete = track_id_with_extras.split(':')
track_id = track_id_incomplete[1].split(',')
track_id_two = track_id[0]
#find track url

url = URI("https://soundcloud-scraper.p.rapidapi.com/v1/track/metadata?track=#{track_id_two}&download=sq")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(url)
request["X-RapidAPI-Key"] = 'bb141578ecmsh6d28efe29ac7316p11e81cjsn2a1ed1dbaddf'
request["X-RapidAPI-Host"] = 'soundcloud-scraper.p.rapidapi.com'

response = http.request(request)
body = response.read_body
track_url = body.split('"')[11]
puts track_url
