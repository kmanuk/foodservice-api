class AddPushCountToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :push_count, :integer, default: 0
  end
end
