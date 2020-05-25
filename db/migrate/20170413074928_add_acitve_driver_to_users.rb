class AddAcitveDriverToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :active_driver, :boolean, default: true
  end
end
