# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require 'faker'
require 'open-uri'
require 'nokogiri'
require 'wikipedia'

puts "Cleaning up database..."
Gig.destroy_all
User.destroy_all
puts "Database cleaned"

venue = [
  "King Tuts Wah Wah Hut, Glasgow",
  "Szimpla, Budapest",
  "Paradiso, Amsterdam",
  "Monarch, Berlin",
  "Whelans, Dublin",
  "The 100 Club, London",
  "Sidecar, Barcelona",
  "Prinzenbar, Hamburg",
  "Madison Square Garden, New York",
  "Sydney Opera House, Sydney",
  "Harpa Concert Hall, Iceland",
  "Hollywood Bowl, Los Angeles",
  "Nippon Budokan, Tokyo",
  "O2 Academy Brixton, London"
]

artists = [
  "The Beatles",
  "The Rolling Stones",
  "Elton John",
  "Stevie Wonder",
  "Ariana Grande",
  "Eminem",
  "Bee Gees",
  "The Temptations",
  "Aretha Franklin",
  "Adele",
  "Lionel Richie",
  "Led Zeppelin",
  "Ed Sheeran",
  "Kanye West",
  "Jake Bugg",
  "Rihanna",
  "Beyonce",
  "Maroon 5",
  "The Notorious B.I.G.",
  "Skepta",
  "The Wombats",
  "Rudimental",
  "Noah And The Whale",
  "Miley Cyrus",
  "Taylor Swift",
  "Lady Gaga",
  "Madonna",
  "Megan Thee Stallion",
  "Tupac",
  "Snoop Dogg",
  "Dr Dre",
  "Post Malone"
]

User.create!(
  user_name: "Admin",
  password: "password",
  email: "admin@admin.com"
)

User.create!(
  user_name: "audra",
  password: "123456",
  email: "a@a.a"
)

80.times do
  Gig.create!(
    user_id: User.first.id,
    name: Faker::Emotion.noun,
    date: Faker::Date.between(from: '2022-11-04', to: '2024-12-31'),
    artist: artists.sample,
    venue: venue.sample
  )
end

UserGig.create!(
  user_id: User.all.sample.id,
  gig_id: Gig.all.sample.id,
  attended: true
)

puts "created #{Gig.all.length} gigs"
puts "created #{User.all.length} users"
puts "created #{UserGig.all.length} users gig"
