require 'stringio'
module Push
  @queue = :push

  def self.perform(spot_user_id, answer_user_id, spot_id)
    users = User.find([spot_user_id, answer_user_id]).group_by(&:id)
    spot_user = users[spot_user_id].first
    answer_user = users[answer_user_id].first

    device_token = spot_user.device_token
    spot = Spot.find(spot_id)
    alert = "#{answer_user.username} found #{spot.hint}!"

    environment = ENV['RACK_ENV'] || 'development'
    cert = StringIO.new(ENV["APPLE_#{environment.upcase}_PUSH_CERT"])

    pusher = Grocer.pusher(
      certificate: cert,
    )
    notification = Grocer::Notification.new(
      device_token: device_token,
      alert: alert,
      badge: 1,
      custom: {
        spot_id: spot.id,
      }
    )
    pusher.push(notification)
  end
end
