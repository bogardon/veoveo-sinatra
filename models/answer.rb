class Answer < ActiveRecord::Base
  include Paperclip::Glue

  belongs_to :user
  belongs_to :spot

  has_attached_file :image, styles: {small: "320x320#", large: "640x640#"}, :default_url => "/images/:style/missing.png"

end
