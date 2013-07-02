collection @spots

attributes :id, :latitude, :longitude, :hint, :created_at

node(:unlocked) do |spot|
  spot.answers.any? do |answer|
    answer.user_id == @current_user.id
  end
end

child :user do
  attributes :id, :username, :email

  node(:following) do |u|
    @user_ids.include? u.id
  end

  node(:avatar_url_thumb) do |u|
    u.avatar.url(:thumb)
  end

  node(:avatar_url_full) do |u|
    u.avatar.url(:full)
  end
end
