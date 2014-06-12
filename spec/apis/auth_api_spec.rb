require 'spec_helper'
describe 'AuthApi' do
  include Rack::Test::Methods
  let(:user) { FactoryGirl.create(:user) }
  describe 'POST /login' do
    context 'when not logged in with a valid username and password' do
      before do
        post '/auth/login', email: user.email, password: user.password
      end
      it 'should return a 201 code' do
        expect(last_response.status).to eq(201)
      end
      it 'should return an api key' do
        response = JSON.parse(last_response.body)
        expect(response['api_key']).to_not be_nil
      end
    end
    context 'when not logged in with an invalid username and password' do
      before do
        post '/auth/login', email: user.email, password: 'lkajsdhflkasjhdf'
      end
      it 'should return a 401 error' do
        expect(last_response.status).to eq(401)
      end
    end
    context 'when the user already has an api key ' do
      before do
        @api_key = FactoryGirl.create(:api_key, user: user)
        post '/auth/login', email: user.email, password: 'herpderpington'
      end
      it 'should return a 201 status' do
        expect(last_response.status).to eq(201)
      end
      it "should return the user's api key" do
        response = JSON.parse(last_response.body)
        expect(response['api_key']).to eq(user.api_key.access_token)
      end
    end
  end
  describe 'DELETE /logout' do
    context 'when logged in' do
      let(:api_key){FactoryGirl.create(:api_key, user: user)}
      before do
        delete '/auth/logout', api_key: api_key.access_token
      end
      it 'should log the user out' do
        expect(last_response.status).to eq(204)
      end
      it "should delete the user's api key" do
        expect(user.api_key).to be_nil
      end
    end
    context 'when not logged in' do
      it 'should respond with 401' do
        delete '/auth/logout', api_key: 'lkjsdhfglksjfdhfg'
        expect(last_response.status).to eq(401)
      end
    end
  end
end
