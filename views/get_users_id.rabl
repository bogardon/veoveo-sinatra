object @user

attributes :id, :username, :email

node(:avatar_url_thumb) do |u|
  u.avatar.url(:thumb)
end

node(:avatar_url_full) do |u|
  u.avatar.url(:full)
end

node(:following) do |u|
  u.reverse_relationships.any? do |r|
    r.follower_id == @current_user.id
  end
end
