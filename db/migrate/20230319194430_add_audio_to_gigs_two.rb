class AddAudioToGigsTwo < ActiveRecord::Migration[7.0]
  def change
    add_column :gigs, :song_two_audio, :string
  end
end
