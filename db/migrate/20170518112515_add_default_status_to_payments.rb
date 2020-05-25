class AddDefaultStatusToPayments < ActiveRecord::Migration[5.0]
  def up
    change_column :payments, :status, :integer, :default => 0
  end

  def down
    change_column :payments, :status, :integer, :default => nil
  end
end
