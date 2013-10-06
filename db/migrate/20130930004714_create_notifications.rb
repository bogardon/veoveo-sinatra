class CreateNotifications < ActiveRecord::Migration
  def up
    create_table :notifications do |t|
      t.references :notifiable, :polymorphic => true
      t.references :src_user
      t.references :dst_user
      t.timestamps
    end
    add_index :notifications, :dst_user_id

    Relationship.all.each do |r|
      r.create_notification
    end

    Answer.all.each do |a|
      s = a.spot
      next if a.user == s.user
      a.create_notification
    end
  end

  def down
    drop_table :notifications
  end
end
