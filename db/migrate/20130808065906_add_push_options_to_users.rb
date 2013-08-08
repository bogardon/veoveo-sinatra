class AddPushOptionsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :spot_answered_push_enabled, :boolean, :default => true
    add_column :users, :spots_nearby_push_enabled, :boolean, :default => true
  end
end
