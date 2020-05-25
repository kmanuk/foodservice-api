class AddFieldsToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :distance, :integer, default: 0
    add_column :orders, :duration, :integer, default: 0
    add_column :orders, :polyline, :text, default: ''
    add_column :orders, :delivery_steps, :jsonb, null: false, default: {}
  end
end
