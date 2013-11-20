collection @answers

attributes :id, :created_at, :user_id

node(:image_url_small) do |answer|
  answer.image.url(:small)
end

node(:image_url_large) do |answer|
  answer.image.url(:large)
end

child :spot do
  attributes :id, :latitude, :longitude, :hint, :created_at, :user_id
end
