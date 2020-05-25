class CreateCancellations < ActiveRecord::Migration[5.0]
  def change
    create_table :cancellations do |t|
      t.integer :who
      t.string :reason
      t.string :status
      t.belongs_to :user
      t.belongs_to :order
      t.timestamps
    end
    add_foreign_key :cancellations, :users, on_delete: :cascade
    add_foreign_key :cancellations, :orders, on_delete: :cascade
  end
end


