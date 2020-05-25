class AddItemIdToLineItems < ActiveRecord::Migration[5.0]
  def change
    add_column :line_items, :item_id, :integer
  end
end
