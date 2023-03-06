class RemoveDateFromGigs < ActiveRecord::Migration[7.0]
  def change
    remove_column :gigs, :date, :string
  end
end
