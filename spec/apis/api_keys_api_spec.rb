require 'spec_helper'
def app
  ApplicationApi
end

describe 'ApiKeysApi' do
  include Rack::Test::Methods
  let(:user) { FactoryGirl.create(:user) }
  describe 'DELETE /api_keys/:value' do
    context 'when an api_key exists' do
      let(:api_key){FactoryGirl.create(:api_key, user: user)}
      before do
        delete "/api_keys/#{api_key.access_token}"
      end
      it 'should be deleted successfully' do
        expect(user.api_key).to be_nil
      end
      it 'should return a 200' do
        expect(last_response.status).to eq(200)
      end
      it "should return an informational response" do
        response= JSON.parse(last_response.body)
        expect(response['status']).to eq('Api Key deleted')
      end
    end
    context 'when an ApiKey does not exist' do
      it 'should return a 404' do
        delete '/api_keys/blahblah'
        expect(last_response.status).to eq(404)
      end
    end

  end
  describe 'POST /api_keys' do
    context 'with a username and password' do
      it 'should create an api key' do
        expect do
          post '/api_keys', email: user.email, password: user.password
        end.to change { ApiKey.count }.by(1)
      end
    end
    context 'with an incorrect password' do
      before do
        post '/api_keys', email: user.email, password: 'blahblahk'
      end
      let(:response) { JSON.parse(last_response.body) }
      it 'should return a 403 error' do
        expect(last_response.status).to eq(403)
      end
      it 'should tell us about invalid credentials' do
        expect(response['error']['code']).to eq('invalid_login')
        expect(response['error']['message']).to include('email and/or password are wrong')
      end
    end
    context 'without a password or an email' do
      before do
        post '/api_keys'
      end
      let(:errors) { JSON.parse(last_response.body) }
      it 'should return a 400 error' do
        expect(last_response.status).to eq(400)
      end
      it 'should complain about a missing password and email' do
        expect(errors['error']['code']).to eq('api_error')
        expect(errors['error']['message']).to include('password is missing')
        expect(errors['error']['message']).to include('email is missing')
      end
    end
  end
end
