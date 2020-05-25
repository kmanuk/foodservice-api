class AddPushCountOrdersToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :push_count_orders, :integer, default: 0
    rename_column :users, :push_count, :push_count_messages
  end
end

