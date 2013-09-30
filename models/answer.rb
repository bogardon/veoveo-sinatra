class Answer < ActiveRecord::Base
  include Paperclip::Glue

  default_scope :order => "created_at DESC"

  belongs_to :user
  belongs_to :spot

  has_attached_file :image,
    styles: {small: "320x320#", large: "640x640#"},
    s3_headers: {'Expires' => 10.year.from_now.httpdate}

  attr_accessible :image

  after_create :remote_push, :if => Proc.new {
    return false if self.user == self.spot.user
    case self.user.spot_answered_push
    when "anyone"
      true
    when "followed"
      self.followed.follows_user(self.follower)
    when "noone"
      false
    end
  }

  def remote_push
    Resque.enqueue(AnswerPush, self.spot.user_id, self.user_id, self.spot.id)
  end
end
