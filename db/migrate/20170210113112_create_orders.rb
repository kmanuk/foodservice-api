class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.references :buyer, index: true, foreign_key: {to_table: :users}
      t.references :seller, index: true, foreign_key: {to_table: :users}
      t.references :driver, index: true, foreign_key: {to_table: :users}
      t.integer :status, null: false, default: 0
      t.datetime :confirmed_at
      t.datetime :pickedup_at
      t.datetime :delivered_at
      t.integer :delivery_type
      t.integer :payment_type
      t.integer :payment_id
      t.decimal :price, precision: 8, scale: 2
      t.decimal :delivery_price, precision: 8, scale: 2
      t.decimal :fee_price, precision: 8, scale: 2
      t.references :address
      t.timestamps
    end

    add_foreign_key :orders, :addresses, on_delete: :cascade
  end
end
