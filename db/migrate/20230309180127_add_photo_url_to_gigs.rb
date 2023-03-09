class AddPhotoUrlToGigs < ActiveRecord::Migration[7.0]
  def change
    add_column :gigs, :photo_url, :string
  end
end
