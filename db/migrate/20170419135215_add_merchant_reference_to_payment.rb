class AddMerchantReferenceToPayment < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :merchant_reference, :string
  end
end
