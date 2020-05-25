class AddLocationToAddress < ActiveRecord::Migration[5.0]
  def change
    add_column :addresses, :location, :string
    remove_column :addresses, :city, :string
    remove_column :addresses, :country, :string
    remove_column :addresses, :street1, :string
    remove_column :addresses, :street2, :string
  end
end
