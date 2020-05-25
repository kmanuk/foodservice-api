class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.belongs_to :sub_category, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.text :description
      t.float :price
      t.integer :amount
      t.float :time_to_cook
      t.integer :type

      t.timestamps
    end
  end
end
