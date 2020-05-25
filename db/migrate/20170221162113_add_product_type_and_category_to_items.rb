class AddProductTypeAndCategoryToItems < ActiveRecord::Migration[5.0]
  def change
    add_reference :items, :product_type, foreign_key: true
    add_reference :items, :category, foreign_key: true
  end
end
