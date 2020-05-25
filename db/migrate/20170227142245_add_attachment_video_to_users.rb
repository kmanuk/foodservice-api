class AddAttachmentVideoToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.attachment :video
    end
  end

  def self.down
    remove_attachment :users, :video
  end
end
