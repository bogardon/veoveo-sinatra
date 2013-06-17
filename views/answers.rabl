object @answer

attributes :id, :created_at

node(:image_url_small) do |answer|
  answer.image.url(:small)
end

node(:image_url_large) do |answer|
  answer.image.url(:large)
end

child :user do
  attributes :id, :username, :email

  node(:avatar_url_thumb) do |u|
    u.avatar.url(:thumb)
  end

  node(:avatar_url_full) do |u|
    u.avatar.url(:full)
  end
end

