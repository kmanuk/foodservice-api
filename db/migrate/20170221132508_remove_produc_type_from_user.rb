class RemoveProducTypeFromUser < ActiveRecord::Migration[5.0]
  def change
    remove_reference :users, :product_type, index: true
  end
end
