require 'spec_helper'

describe 'The VeoVeo App' do
  before :all do
    authorize 'veoveo', 'lolumad'
  end

  before :all do
    @user = User.new
    @user.username = "bogardon"
    @user.password_plain = "veoveo"
    @user.email = "bogardon@gmail.com"
    @user.save
  end

  describe 'get /' do
    before :all do
      get '/'
    end

    it 'should succeed' do
      expect(last_response).to be_ok
      expect(last_response.body).to eq('Hello, world!')
    end
  end

  describe 'post /users/signin' do

    context 'correct credentials' do
      before :all do
        post '/users/signin', :username => "bogardon", :password => "veoveo"
      end

      it 'should succeed' do
        expect(last_response.status).to eq(201)
      end
    end

    context 'incorrect credentials' do
      before :all do
        post '/users/signin', :username => "bogardon", :password => "wrong"
      end

      it 'should fail' do
        expect(last_response.status).to eq(400)
      end
    end

  end

  describe 'get /spots/:id' do
    before :all do
      @spot = Spot.new
      @spot.user = @user
      @spot.hint = "test test"
      @spot.latitude = @spot.longitude = 0
      @spot.save
    end

    context 'with an existing spot' do
      before :all do
        get "spots/#{@spot.id}", nil, {'HTTP_X_VEOVEO_API_TOKEN' => @user.api_token}
      end

      it 'should succeed' do
        expect(last_response.status).to eq(200)

      end

      it 'should get the right spot' do
        expect(JSON.parse(last_response.body)["id"]).to eq(@spot.id)
      end

    end

    context 'with an nonexistent spot' do
      before :all do
        get "spots/#{@spot.id+1}", nil, {'HTTP_X_VEOVEO_API_TOKEN' => @user.api_token}
      end

      it 'should return error' do
        expect(last_response.status).to eq(400)
      end
    end
  end


  describe 'post /user/facebook' do

    context 'when facebook succeeds' do
      before :all do
        Koala::Facebook::API.any_instance.stubs(:get_object).with('me').returns({"id" => 1})
        post '/users/facebook', {'facebook_access_token' => '123', 'facebook_expires_at' => Time.now.to_s}, {'HTTP_X_VEOVEO_API_TOKEN' => @user.api_token}
      end

      it 'should succeed' do
        expect(last_response.status).to eq(201)
      end
      it 'should set facebook_id' do
        subject
        expect(@user.reload.facebook_id).to eq(1.to_s)
      end
    end
  end

end
