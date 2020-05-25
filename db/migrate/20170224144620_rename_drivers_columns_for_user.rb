class RenameDriversColumnsForUser < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :certified, :certified_driver
    rename_column :users, :approved, :approved_driver
    rename_column :users, :active, :recommended_seller
  end
end
