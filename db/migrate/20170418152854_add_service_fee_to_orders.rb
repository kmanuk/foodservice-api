class AddServiceFeeToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :service_fee, :decimal, precision: 8, scale: 2, after: :fee_price
  end
end
