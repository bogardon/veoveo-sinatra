class User < ActiveRecord::Base
  include Paperclip::Glue

  attr_accessible :avatar, :username, :password, :email

  # relations
  has_many :spots, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_attached_file :avatar, styles: {thumb: "100x100#", full: "640x640#"}
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :reverse_relationships, foreign_key: "followed_id", class_name: "Relationship", dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
  has_many :followed_users, through: :relationships, source: :followed

  # filters
  before_create :encrypt_password, :generate_api_token

  def self.sign_in(json)
    username = json['username']
    user = User.find_by_username username
    if user && user.password != Digest::SHA1.base64digest(json['password'])
      user.errors.messages[:password] = "incorrect password"
    end
    user
  end

  def self.sign_up(json)
    user = User.new username: json['username'], password: json['password'], email: json['email']
    user.save
    user
  end

  def encrypt_password
    self.password = Digest::SHA1.base64digest(self.password)
  end

  def generate_api_token
    # Generate a random hexadecimal string to use as the API token.
    # Check to see if another key exists with the same token and regenerates the token if this is the case.
    begin
      self.api_token = SecureRandom.hex
    end while self.class.exists?(api_token: api_token)
  end

  def avatar_url_thumb
    avatar.url(:thumb)
  end

  def avatar_url_full
    avatar.url(:full)
  end
end
