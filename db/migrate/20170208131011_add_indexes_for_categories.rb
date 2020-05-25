class AddIndexesForCategories < ActiveRecord::Migration[5.0]
  def change
    add_index :categories, :lang
    add_index :sub_categories, :lang
  end
end
