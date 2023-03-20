class AddSongsToGigsTwo < ActiveRecord::Migration[7.0]
  def change
    add_column :gigs, :song_two, :string
  end
end
