class AddAudioToGigsThree < ActiveRecord::Migration[7.0]
  def change
    add_column :gigs, :song_three_audio, :string
  end
end
