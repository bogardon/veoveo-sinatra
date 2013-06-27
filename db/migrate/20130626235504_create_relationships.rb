class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.references :follower
      t.references :followed
      t.timestamps
    end
  end
  add_index :relationships, :follower_id
  add_index :relationships, :followed_id
  add_index :relationships, [:follower_id, :followed_id], unique: true
end
