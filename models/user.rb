class User < ActiveRecord::Base
  has_one :facebook
  before_create :encrypt_password

  def encrypt_password
    self.password = Digest::SHA1.base64digest(self.password)
  end

  def self.create(username, password, email)
    return nil unless username && password && email
    user = User.new username: username, password: password, email: email
    user.save
    user
  end
end
