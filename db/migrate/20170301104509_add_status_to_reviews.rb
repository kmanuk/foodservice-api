class AddStatusToReviews < ActiveRecord::Migration[5.0]
  def change
    add_column :reviews, :status, :string
  end
end
