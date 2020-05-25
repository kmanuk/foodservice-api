class AddApprovedAtToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :approved, :boolean, default: false
    add_column :users, :certified, :boolean, default: false
  end
end
