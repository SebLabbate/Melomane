require 'wikipedia'
require 'rspotify'
require 'uri'
require 'net/http'
require 'openssl'
require 'pexels'
require 'json'

url = URI("https://app.ticketmaster.com/discovery/v2/events.json?apikey=dQnJo7HE3HCwNKc3HbpQvCF3ps9exT7y&keyword=raye")
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
request = Net::HTTP::Get.new(url)
response = http.request(request)
events = response.read_body
gigs = JSON.parse(events)
events_hash = gigs["_embedded"]
puts events_hash[0..2]
