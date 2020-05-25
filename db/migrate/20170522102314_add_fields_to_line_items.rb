class AddFieldsToLineItems < ActiveRecord::Migration[5.0]
  def self.up
    change_table :line_items do |t|
      t.float :time_to_cook, default: 0.0
      t.string :image_url
    end
  end

  def self.down
    remove_column :line_items, :image_url, :string
    remove_column :line_items, :time_to_cook, :float
  end

end
