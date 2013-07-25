class AddFacebookToUsers < ActiveRecord::Migration
  def change
    add_column :users, :facebook_expires_at, :datetime
    add_column :users, :facebook_access_token, :string
    add_column :users, :facebook_id, :string
    add_index :users, :facebook_id
  end
end
