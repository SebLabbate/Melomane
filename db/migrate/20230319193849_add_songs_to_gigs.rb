class AddSongsToGigs < ActiveRecord::Migration[7.0]
  def change
    add_column :gigs, :song_one, :string
  end
end
