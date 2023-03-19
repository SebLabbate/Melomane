class AddPhotoTwoToGigs < ActiveRecord::Migration[7.0]
  def change
    add_column :gigs, :photo_url_two, :string
  end
end
