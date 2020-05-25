class CreateSubCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :sub_categories do |t|
      t.string :name
      t.string :description
      t.string :lang
      t.references :category, index: true, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
