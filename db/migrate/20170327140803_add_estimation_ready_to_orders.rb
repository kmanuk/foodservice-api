class AddEstimationReadyToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :estimation_ready, :timestamp
  end
end
