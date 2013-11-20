module FacebookPush
  @queue = :push

  def self.perform(user_id)
    user = User.find(user_id)

    facebook_me = user.facebook_me
    facebook_friend_ids = user.facebook_friend_ids
    facebook_friends = User.includes(:relationships).where(:facebook_id => facebook_friend_ids).reject do |u|
      u.follows_user?(user) || u.device_token == nil
    end

    return if facebook_friends.empty?

    environment = ENV['RACK_ENV'] || 'development'
    # dont know why but heroku env variables escape \n into \\n
    cert = StringIO.new(ENV["APPLE_#{environment.upcase}_PUSH_CERT"].gsub("\\n","\n"))

    pusher = Grocer.pusher(
      certificate: cert,
    )

    alert = "#{facebook_me['first_name']} #{facebook_me['last_name']} just joined VeoVeo!"

    notifications = facebook_friends.map do |u|
      Grocer::Notification.new(
        device_token: u.device_token,
        alert: alert,
        badge: 1,
        sound: "default",
        custom: {
          user_id: user.id,
        }
      )
    end

    notifications.each do |notification|
      pusher.push(notification)
    end
  end
end
