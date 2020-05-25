class RemaneUuidToToken < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :uuid, :token
  end
end
