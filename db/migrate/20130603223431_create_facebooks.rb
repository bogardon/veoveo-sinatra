class CreateFacebooks < ActiveRecord::Migration
  def change
    create_table :facebooks do |t|
      t.string :uid
      t.string :access_token
      t.datetime :expires_at
      t.references :user
      t.timestamps
    end
    add_index :facebooks, :uid, :unique => true
    add_index :facebooks, :user_id
  end
end
