class AddReferenceToComments < ActiveRecord::Migration[7.0]
  def change
    add_reference :comments, :user_gig, foreign_key: true
  end
end
