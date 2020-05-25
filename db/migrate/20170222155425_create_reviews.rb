class CreateReviews < ActiveRecord::Migration[5.0]
  def change
    create_table :reviews do |t|
      t.integer :rate
      t.string :message

      t.references :ratable, polymorphic: true
      t.references :reviewer, index: true, foreign_key: {to_table: :users}
      t.timestamps
    end
  end
end
