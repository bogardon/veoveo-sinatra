class CreateSpots < ActiveRecord::Migration
  def change
    create_table :spots do |t|
      t.string :hint
      t.float :latitude
      t.float :longitude
      t.references :user
      t.timestamps
    end
    add_index :spots, [:latitude, :longitude]
  end
end
