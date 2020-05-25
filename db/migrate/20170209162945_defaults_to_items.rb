class DefaultsToItems < ActiveRecord::Migration[5.0]
  def change
    change_column_default :items, :price, 0.0
    change_column_default :items, :amount, 1
    change_column_default :items, :time_to_cook, 0.0

  end
end
