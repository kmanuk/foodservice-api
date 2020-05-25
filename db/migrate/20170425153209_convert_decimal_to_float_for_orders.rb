class ConvertDecimalToFloatForOrders < ActiveRecord::Migration[5.0]
  def change
    change_column :orders, :price, :float
    change_column :orders, :total_price, :float
    change_column :orders, :fee_price, :float
    change_column :orders, :delivery_price, :float
    change_column :orders, :service_fee, :float
    change_column :orders, :global_price, :float
  end
end
