class RecalculatePriceForItems < ActiveRecord::Migration[5.0]
  class Item < ApplicationRecord
    self.inheritance_column = nil
  end

  def up
    Item.find_each do |item|
      item.update_column(:total_price, item.price + item.price * 0.1)
    end
  end
end
