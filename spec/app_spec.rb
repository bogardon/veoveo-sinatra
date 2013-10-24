require 'spec_helper'

describe 'The VeoVeo App' do
  before :all do
    authorize 'veoveo', 'lolumad'
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

    before :all do
      @user = User.new
      @user.username = "bogardon"
      @user.password_plain = "veoveo"
      @user.email = "bogardon@gmail.com"
      @user.save
    end

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
end
