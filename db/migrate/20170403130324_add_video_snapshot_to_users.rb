class AddVideoSnapshotToUsers < ActiveRecord::Migration[5.0]
  def self.up
    change_table :users do |t|
      t.attachment :video_snapshot
    end
  end

  def self.down
    remove_attachment :users, :video_snapshot
  end

end
