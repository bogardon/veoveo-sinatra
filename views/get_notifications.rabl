collection @notifications

attributes :id, :created_at, :notifiable_type, :notifiable_id, :unread

child :src_user => :src_user do
  attributes :id, :username, :email

  node(:avatar_url_thumb) do |u|
    u.avatar.url(:thumb)
  end

  node(:avatar_url_full) do |u|
    u.avatar.url(:full)
  end
end

child :notifiable => :notifiable do |n|
  if n.is_a?(Answer)
    attributes :id, :created_at
    child :spot do |s|
      attributes :id, :latitude, :longitude, :hint, :created_at, :user_id
    end
  else
    nil
  end
end

# node(:answer) do |n|
#   case n.notifiable_type
#   when "Answer"
#     p 'answer'
#     child :notifiable => :answer do |a|
#       attributes :id, :created_at
#       child :spot do |s|
#         attributes :id, :latitude, :longitude, :hint, :created_at, :user_id
#       end
#     end
#   when "Relationship"
#     p 'relationship '
#     child :notifiable => :relationship do |r|
#       attributes :id
#     end
#   end
# end

# node(:relationship) do |n|
#   if n.notifiable.is_a?(Relationship)
#     child :notifiable => :relationship do |s|
#       attributes :id
#     end
#   else
#     nil
#   end
# end
