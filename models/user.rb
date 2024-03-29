class User < ActiveRecord::Base
  include Paperclip::Glue

  attr_accessible :avatar, :username, :password, :email, :spot_answered_push, :spots_nearby_push, :followed_push

  attr_accessor :password_plain

  # relations
  has_many :spots, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_attached_file :avatar,
    styles: {thumb: "100x100#", full: "640x640#"},
    s3_headers: {'Expires' => 10.year.from_now.httpdate}
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :reverse_relationships, foreign_key: "followed_id", class_name: "Relationship", dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
  has_many :followed_users, through: :relationships, source: :followed

  # filters
  before_create :generate_api_token

  before_save :encrypt_password

  after_save :notify_facebook_friends, :if => Proc.new {
    self.facebook_id && self.facebook_id_changed?
  }

  def self.sign_in(json)
    username = json['username']
    user = User.find_by_username username
    if user && user.password != Digest::SHA1.base64digest(json['password'])
      user.errors.messages[:password] = "incorrect password"
    end
    user
  end

  def self.sign_up(json)
    user = User.new username: json['username'], email: json['email']
    user.password_plain = json['password']
    user.save
    user
  end

  def notify_facebook_friends
    Resque.enqueue(FacebookPush, self.id)
  end

  def encrypt_password
    return unless self.password_plain
    self.password = Digest::SHA1.base64digest(self.password_plain)
  end

  def generate_api_token
    # Generate a random hexadecimal string to use as the API token.
    # Check to see if another key exists with the same token and regenerates the token if this is the case.
    begin
      self.api_token = SecureRandom.hex
    end while self.class.exists?(api_token: api_token)
  end

  def facebook_connected?
    self.facebook_id? && self.facebook_access_token?
  end

  def follows_user_on_facebook?(user)
    return false unless self.facebook_connected? && user.facebook_connected?
    self.facebook_friend_ids.include? user.facebook_id
  end

  def facebook_me
    graph = Koala::Facebook::API.new(self.facebook_access_token)
    graph.get_object('me')
  end

  def facebook_friend_ids
    return [] unless self.facebook_connected?
    graph = Koala::Facebook::API.new(self.facebook_access_token)
    me_friends = graph.get_object('me/friends')
    facebook_ids = me_friends.map do |friend|
      friend['id']
    end
    facebook_ids
  end

  def follows_user?(user)
    self.relationships.map(&:followed_id).include? user.id
  end

  def followed_by_user?(user)
    self.reverse_relationships.map(&:follower_id).include? user.id
  end

  def avatar_url_thumb
    avatar.url(:thumb)
  end

  def avatar_url_full
    avatar.url(:full)
  end
end
