class RenameCommentsColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :comments, :comment, :content
  end
end
