class Answer < ActiveRecord::Base
  include Paperclip::Glue

  default_scope :order => "created_at DESC"

  belongs_to :user
  belongs_to :spot

  has_attached_file :image, styles: {small: "320x320#", large: "640x640#"}

  attr_accessible :image

end
