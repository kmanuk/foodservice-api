class AddIndexes < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :latitude
    add_index :users, :longitude

    add_index :addresses, :latitude
    add_index :addresses, :longitude
  end
end
