class CreateAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :addresses do |t|
      t.string :street1
      t.string :street2
      t.string :city
      t.string :country
      t.string :state
      t.string :zip, limit: 10
      t.decimal :latitude
      t.decimal :longitude
      t.timestamps
    end

    change_table :users do |t|
      t.belongs_to :address
    end

    add_foreign_key :users, :addresses, on_delete: :cascade
  end
end
