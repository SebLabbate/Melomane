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

puts "created #{User.all.length} users"
