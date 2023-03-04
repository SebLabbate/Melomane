# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require 'faker'
require 'open-uri'

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
  "Prinzenbar, Hamburg"
]

artist = [
  "The Beatles",
  "The Rolling Stones",
  "Elton John",
  "Stevie Wonder",
  "Drake",
  "Eminem",
  "Bee Gees",
  "The Temptations",
  "Aretha Franklin",
  "Adele",
  "Lionel Richie",
  "Led Zeppelin"
]

genre = [
  "Rock n Roll",
  "Heavy Metal",
  "Soul",
  "Funk",
  "Hip-hop"
]

User.create!(
  user_name: "Admin",
  password: "password",
  email: "admin@admin.com"
)

20.times do
  Gig.create!(
    user_id: 1,
    name: Faker::Emotion.noun,
    date: Faker::Date.between(from: '2023-03-04', to: '2024-12-31'),
    artist: artist.sample,
    venue: venue.sample,
    genre: genre.sample
  )
end

puts "created #{Gig.all.length} gigs"
puts "created #{User.all.length} users"
