class ChangeAddressModel < ActiveRecord::Migration[5.0]
  def change
    change_column :addresses, :latitude, :float
    change_column :addresses, :longitude, :float
    remove_column :addresses, :state, :state
    remove_column :addresses, :zip, limit: 10
  end
end
