require 'wikipedia'
require 'rspotify'
require 'uri'
require 'net/http'
require 'openssl'

def find_events_array_by_name
  url = URI("https://app.ticketmaster.com/discovery/v2/events.json?apikey=dQnJo7HE3HCwNKc3HbpQvCF3ps9exT7y&locale=*&city=london&classificationName=music")
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
  events_hash_two
  event = events_hash_two[0]
  artist_name = event["_embedded"]["attractions"][0]["name"]
  return artist_name
end

puts artist = find_events_array_by_name
