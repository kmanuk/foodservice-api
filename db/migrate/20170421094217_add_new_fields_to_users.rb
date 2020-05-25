class AddNewFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :iban, :string
    add_column :users, :bank_name, :string
    add_column :users, :car_type, :string
    add_column :users, :plate_number, :string
    add_column :users, :driver_license, :string
    add_column :users, :insurance_name, :string
    add_column :users, :insurance_number, :string
  end
end
