class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.references :user
      t.references :spot
      t.attachment :image
      t.timestamps
    end
    add_index :answers, :spot_id
    add_index :answers, :user_id
  end
end
