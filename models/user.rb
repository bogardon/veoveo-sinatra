class User < ActiveRecord::Base
  has_one :facebook
  before_create :encrypt_password
  validates_uniqueness_of :username, :email
  validates_presence_of :username, :email, :password

  def encrypt_password
    self.password = Digest::SHA1.base64digest(self.password)
  end

  def self.sign_up(json)
    user = User.new username: json['username'], password: json['password'], email: json['email']
    user.save
    user
  end

  def to_json
    super :except => [:password]
  end
end
