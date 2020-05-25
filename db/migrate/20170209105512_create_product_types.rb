class CreateProductTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :product_types do |t|
      t.string :name
      t.string :lang
      t.timestamps
    end

    change_table :categories do |t|
      t.references :product_type
    end

    change_table :users do |t|
      t.belongs_to :product_type
    end

    add_foreign_key :categories, :product_types
    add_foreign_key :users, :product_types



  end
end
