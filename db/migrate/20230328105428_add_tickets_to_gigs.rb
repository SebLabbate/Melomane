class AddTicketsToGigs < ActiveRecord::Migration[7.0]
  def change
    add_column :gigs, :tickets, :string
  end
end
