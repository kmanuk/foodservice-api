class ChangeRateType < ActiveRecord::Migration[5.0]
  def up
    change_column :reviews, :rate, :float
  end

  def down
    change_column :reviews, :rate, :integer
  end
end
