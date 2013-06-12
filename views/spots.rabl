collection @spots

attributes :id, :latitude, :longitude, :hint

node(:unlocked) do |spot|
  spot.answers.any? do |answer|
    answer.user_id == @current_user.id
  end
end
