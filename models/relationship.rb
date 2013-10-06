class Relationship < ActiveRecord::Base
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  after_create :remote_push, :if => Proc.new {
    case self.followed.followed_push
    when "anyone"
      true
    when "followed"
      self.followed.follows_user(self.follower)
    when "noone"
      false
    end
  }

  after_create :create_notification

  def remote_push
    Resque.enqueue(FollowPush, self.follower_id, self.followed_id)
  end

  def create_notification
    n = Notification.new
    n.notifiable = self
    n.dst_user = self.followed
    n.src_user = self.follower
    n.created_at = self.created_at
    n.updated_at = self.updated_at
    n.save
  end
end
