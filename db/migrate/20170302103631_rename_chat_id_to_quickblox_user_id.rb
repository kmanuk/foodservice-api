class RenameChatIdToQuickbloxUserId < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :chat_id, :quickblox_user_id
  end
end
