class AddTypeToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :type, :integer
  end
end
