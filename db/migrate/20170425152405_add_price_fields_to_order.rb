class AddPriceFieldsToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :total_price, :decimal, precision: 8, scale: 2
    add_column :orders, :global_price, :decimal, precision: 8, scale: 2
  end
end
