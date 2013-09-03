module FollowPush
  @queue = :push

  def self.perform(follower_user_id, followed_user_id)

    users = User.find([follower_user_id, followed_user_id]).group_by(&:id)
    follower = users[follower_user_id].first
    followed = users[followed_user_id].first

    device_token = followed.device_token

    return unless device_token

    alert = "#{follower.username} followed you!"

    environment = ENV['RACK_ENV'] || 'development'
    # dont know why but heroku env variables escape \n into \\n
    cert = StringIO.new(ENV["APPLE_#{environment.upcase}_PUSH_CERT"].gsub("\\n","\n"))

    pusher = Grocer.pusher(
      certificate: cert,
    )
    notification = Grocer::Notification.new(
      device_token: device_token,
      alert: alert,
      badge: 1,
      custom: {
        user_id: follower.id,
      }
    )
    pusher.push(notification)
  end
end
