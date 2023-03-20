class AddAudioToGigs < ActiveRecord::Migration[7.0]
  def change
    add_column :gigs, :song_one_audio, :string
  end
end
