class ChangeItemType < ActiveRecord::Migration[5.0]
  def change
    change_column :items, :type, :string

    add_index :items, :type
  end
end
