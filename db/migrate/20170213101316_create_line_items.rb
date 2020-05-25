class CreateLineItems < ActiveRecord::Migration[5.0]
  def change
    create_table :line_items do |t|
      t.references :item, index: true
      t.references :order, index: true
      t.decimal :price, precision: 8, scale: 2
      t.integer :quantity
      t.timestamps
    end

    add_foreign_key :line_items, :orders, on_delete: :cascade
    add_foreign_key :line_items, :items
  end
end
