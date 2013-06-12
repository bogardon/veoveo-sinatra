class Spot < ActiveRecord::Base
  belongs_to :user
  has_many :answers

  def serializable_hash(options={})

    super options.merge(:except => [:created_at,
                      :updated_at,
                      :user_id])
  end
end
