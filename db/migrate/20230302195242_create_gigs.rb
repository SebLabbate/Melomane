class CreateGigs < ActiveRecord::Migration[7.0]
  def change
    create_table :gigs do |t|
      t.string :name
      t.string :date
      t.string :artist
      t.string :venue
      t.string :genre
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
