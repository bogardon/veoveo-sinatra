class Notification < ActiveRecord::Base
  attr_accessible :dst_user, :src_user, :notifiable

  default_scope :order => "created_at DESC"

  belongs_to :notifiable, :polymorphic => true
  belongs_to :dst_user, :class_name => "User"
  belongs_to :src_user, :class_name => "User"
end
