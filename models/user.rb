class User < ActiveRecord::Base
  include Paperclip::Glue

  attr_accessible :avatar, :username, :password, :email

  # relations
  has_one :facebook
  has_many :spots
  has_many :answers
  has_attached_file :avatar, styles: {thumb: "100x100#", full: "640x640#"}

  # filters
  before_create :encrypt_password, :generate_api_token

  # validations
  validates_uniqueness_of :username, :email
  validates_presence_of :username, :email, :password

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

  def as_json(options)
    super options.merge(:except => [:password,
                      :updated_at,
                      :created_at,
                      :avatar_content_type,
                      :avatar_file_size,
                      :avatar_updated_at,
                      :avatar_file_name],
          :methods => [:avatar_url_thumb,
                       :avatar_url_full])
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
