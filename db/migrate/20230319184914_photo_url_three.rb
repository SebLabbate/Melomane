class PhotoUrlThree < ActiveRecord::Migration[7.0]
  def change
    add_column :gigs, :photo_url_three, :string
  end
end
