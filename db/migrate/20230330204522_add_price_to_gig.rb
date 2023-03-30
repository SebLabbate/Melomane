class AddPriceToGig < ActiveRecord::Migration[7.0]
  def change
    add_column :gigs, :gig_price, :string
  end
end
