class ChangeDefaultsForNotifications < ActiveRecord::Migration
  def up
    change_column_default :users, :spots_nearby_push, "followed"
  end

  def down
    change_column_default :users, :spots_nearby_push, "anyone"
  end
end
