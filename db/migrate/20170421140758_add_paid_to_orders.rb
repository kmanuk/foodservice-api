class AddPaidToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :paid, :boolean, default: false
  end
end
