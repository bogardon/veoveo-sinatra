# app.rb

before do
  content_type 'application/json'
end

get '/' do
  "Hello, world!"
end

post 'facebook_connect' do

end
