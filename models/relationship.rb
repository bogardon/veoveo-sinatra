class Relationship < ActiveRecord::Base
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  after_create :remote_push

  def remote_push
    Resque.enqueue(FollowPush, self.follower_id, self.followed_id)
  end
end
