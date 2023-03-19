require 'wikipedia'
require 'rspotify'
require 'uri'
require 'net/http'
require 'openssl'
require 'pexels'

def pexel_photos
  client = Pexels::Client.new('41EOfTlvkrnn8r297MvVFXPjmYq2jLs9OGSGZLfrQpDRmFVXMvMJdCHO')
  photo = client.photos.search('concert').to_a
  first = photo[rand(1..12)].src
  array = []
  first.each_value do |value|
    array << value
  end
  return array
end

puts pexel_photos
