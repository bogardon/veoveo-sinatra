class Spot < ActiveRecord::Base
  belongs_to :user
  has_many :answers

  def to_json
    super :except => [:created_at,
                      :updated_at,
                      :user_id]
  end
end
