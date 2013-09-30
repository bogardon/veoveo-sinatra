class ChangePushOptionsForUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :spot_answered_push_enabled
    remove_column :users, :spots_nearby_push_enabled
    add_column :users, :spot_answered_push, :string, :default => "anyone"
    add_column :users, :spots_nearby_push, :string, :default => "anyone"
    add_column :users, :followed_push, :string, :default => "anyone"
  end

  def self.down
    add_column :users, :spot_answered_push_enabled, :boolean, :default => true
    add_column :users, :spots_nearby_push_enabled, :boolean, :default => true
    remove_column :users, :spot_answered_push
    remove_column :users, :spots_nearby_push
    remove_column :users, :followed_push
  end
end
