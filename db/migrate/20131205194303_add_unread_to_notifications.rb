class AddUnreadToNotifications < ActiveRecord::Migration
  def up
    add_column :notifications, :unread, :boolean, :default => true
    Notification.update_all :unread => false
  end

  def down
    remove_column :notifications, :unread
  end
end
