class AddPhotoFiveToGigs < ActiveRecord::Migration[7.0]
  def change
    add_column :gigs, :photo_url_five, :string
  end
end
