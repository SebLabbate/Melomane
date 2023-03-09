# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_03_05_154944) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "gigs", force: :cascade do |t|
    t.string "name"
    t.string "date"
    t.string "artist"
    t.string "venue"
    t.string "genre"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "artist_info"
    t.index ["user_id"], name: "index_gigs_on_user_id"
  end

  create_table "user_gigs", force: :cascade do |t|
    t.string "comment"
    t.boolean "attended", default: false
    t.bigint "user_id", null: false
    t.bigint "gig_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gig_id"], name: "index_user_gigs_on_gig_id"
    t.index ["user_id"], name: "index_user_gigs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "gigs", "users"
  add_foreign_key "user_gigs", "gigs"
  add_foreign_key "user_gigs", "users"
end
