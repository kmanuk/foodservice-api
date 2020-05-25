class AddIpAddressToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :ip_address, :string
  end
end
