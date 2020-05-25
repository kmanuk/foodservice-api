class ChangeTypeForStatus < ActiveRecord::Migration[5.0]
  def change
    remove_column :payments, :status, :string
    add_column :payments, :status, :integer
  end
end
