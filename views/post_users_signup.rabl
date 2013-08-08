object @user

attributes :id, :username, :email, :api_token, :spot_answered_push_enabled, :spots_nearby_push_enabled

node(:avatar_url_thumb) do |u|
  u.avatar.url(:thumb)
end

node(:avatar_url_full) do |u|
  u.avatar.url(:full)
end
