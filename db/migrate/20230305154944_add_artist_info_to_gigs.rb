class AddArtistInfoToGigs < ActiveRecord::Migration[7.0]
  def change
    add_column :gigs, :artist_info, :string
  end
end
