class CreatePayments < ActiveRecord::Migration[5.0]
  def change
    create_table :payments do |t|
      t.string :token
      t.string :card_number
      t.string :expiry_date
      t.string :card_bin
      t.string :card_holder_name
      t.string :remember
      t.string :status
      t.references :order, index: true, foreign_key: true
      t.timestamps
    end
  end
end
