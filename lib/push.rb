module Push
  @queue = :apple_push

  def self.perform(dst_user_id, src_user_id, spot_id)
    dst_user, src_user = User.where(:id => [dst_user_id, src_user_id]).to_a
    device_token = dst_user.device_token
    spot = Spot.find(spot_id)
    alert = "#{dst_user.username} found #{spot.hint}!"

    pusher = Grocer.pusher(
      certificate: "./veoveo_push_certificate.pem",      # required
      gateway:     "gateway.push.apple.com", # optional; See note below.
      port:        2195,                     # optional
      retries:     3                         # optional
    )
    notification = Grocer::Notification.new(
      device_token:      device_token,
      alert:             alert,
      badge:             1,
    )
  end
end
