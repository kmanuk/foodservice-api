class ReorderItemTypes < ActiveRecord::Migration[5.0]
  class Item < ApplicationRecord
    self.inheritance_column = nil
  end

  def up
    types = %w(free live preorder)

    Item.find_each do |i|
      i.update_column(:type, types[i.type.to_i])
    end
  end
end
