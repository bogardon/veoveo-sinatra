class User < ActiveRecord::Base
  has_one :facebook
  before_create :encrypt_password
  validates_uniqueness_of :username, :email
  validates_presence_of :username, :email, :password

  def self.sign_in(json)
    username = json['username']
    user = User.find_by_username username
    user.errors.messages[:username] = "who is #{username}?" if user.nil?
    verified = user.password == Digest::SHA1.base64digest(json['password'])
    user.errors.messages[:password] = "incorrect password" unless verified
    user
  end

  def self.sign_up(json)
    user = User.new username: json['username'], password: json['password'], email: json['email']
    user.save
    user
  end

  def to_json
    super :except => [:password]
  end

  def encrypt_password
    self.password = Digest::SHA1.base64digest(self.password)
  end
end
