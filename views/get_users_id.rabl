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

child :answers, :object_root => false do
  attributes :id, :created_at

  node(:image_url_small) do |answer|
    answer.image.url(:small)
  end

  node(:image_url_large) do |answer|
    answer.image.url(:large)
  end

  child :spot do
    attributes :id, :latitude, :longitude, :hint, :created_at
  end

end

