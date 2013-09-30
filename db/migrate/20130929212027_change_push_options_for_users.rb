class ChangePushOptionsForUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :spot_answered_push, :string, :default => "anyone"
    add_column :users, :spots_nearby_push, :string, :default => "anyone"
    add_column :users, :followed_push, :string, :default => "anyone"
  end

  def self.down
    remove_column :users, :spot_answered_push
    remove_column :users, :spots_nearby_push
    remove_column :users, :followed_push
  end
end
