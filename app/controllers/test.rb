require 'uri'
require 'net/http'
require 'openssl'

url = URI("https://concerts-artists-events-tracker.p.rapidapi.com/location?name=London&minDate=2022-05-20&maxDate=2024-04-19&page=1")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(url)
request["X-RapidAPI-Key"] = 'bb141578ecmsh6d28efe29ac7316p11e81cjsn2a1ed1dbaddf'
request["X-RapidAPI-Host"] = 'concerts-artists-events-tracker.p.rapidapi.com'

response = http.request(request)
puts response.read_body
