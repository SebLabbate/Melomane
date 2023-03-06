class AddDateToGigs < ActiveRecord::Migration[7.0]
  def change
    add_column :gigs, :date, :datetime
  end
end
