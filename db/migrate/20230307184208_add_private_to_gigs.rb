class AddPrivateToGigs < ActiveRecord::Migration[7.0]
  def change
    add_column :gigs, :private, :boolean, default: false
  end
end
