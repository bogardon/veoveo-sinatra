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
    end

    it 'should have correct body' do
      expect(last_response.body).to eq('Hello, world!')
    end
  end
end
