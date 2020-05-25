class ChangeCategoriesStructure < ActiveRecord::Migration[5.0]
  def change
    rename_column :product_types, :name, :en
    rename_column :categories, :name, :en
    rename_column :sub_categories, :name, :en

    remove_index :categories, :lang
    remove_index :sub_categories, :lang

    rename_column :product_types, :lang, :ar
    rename_column :categories, :lang, :ar
    rename_column :sub_categories, :lang, :ar
  end
end
