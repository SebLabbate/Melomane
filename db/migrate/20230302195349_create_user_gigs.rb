class CreateUserGigs < ActiveRecord::Migration[7.0]
  def change
    create_table :user_gigs do |t|
      t.string :comment
      t.boolean :attended, default: false
      t.references :user, null: false, foreign_key: true
      t.references :gig, null: false, foreign_key: true

      t.timestamps
    end
  end
end
