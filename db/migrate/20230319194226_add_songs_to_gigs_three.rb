class AddSongsToGigsThree < ActiveRecord::Migration[7.0]
  def change
    add_column :gigs, :song_three, :string
  end
end
