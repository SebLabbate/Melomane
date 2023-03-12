class ChangePhotoUrlInGigs < ActiveRecord::Migration[7.0]
  def change
    rename_column :gigs, :photo_url, :wiki_photo_url
  end
end
