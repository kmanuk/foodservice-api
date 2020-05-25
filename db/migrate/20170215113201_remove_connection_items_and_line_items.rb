class RemoveConnectionItemsAndLineItems < ActiveRecord::Migration[5.0]
  def change
    remove_reference(:line_items, :item, index: true)

    change_table :line_items do |t|
      t.decimal :total_price, precision: 8, scale: 2
      t.string :name
    end

  end
end
