class AddTotalPriceToItems < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :total_price, :float
  end
end
