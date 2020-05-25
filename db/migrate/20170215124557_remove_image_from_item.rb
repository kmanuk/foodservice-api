class RemoveImageFromItem < ActiveRecord::Migration[5.0]
  def up
    remove_attachment :items, :image
  end

  def down
    change_table :items do |t|
      t.attachment :image
    end
  end
end
