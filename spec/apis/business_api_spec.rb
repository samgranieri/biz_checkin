require 'spec_helper'
def app
  ApplicationApi
end
describe BusinessesApi do
  include Rack::Test::Methods
  describe 'GET /businesses' do
    it 'returns a list of all Businesses' do
      business = FactoryGirl.create(:business)
      get '/businesses'
      expect(last_response.body).to eq({ data: [BusinessRepresenter.new(business)] }.to_json)
    end
  end
  describe 'GET /businesses/:id' do
    it 'should return a business given an id' do
      business = FactoryGirl.create(:business)
      get "/businesses/#{business.id}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq({ data: BusinessRepresenter.new(business) }.to_json)
    end
  end
  describe 'PUT /businesses/:id' do
    it 'should update a business if needed' do
      business = FactoryGirl.create(:business)
      put "/businesses/#{business.id}", name: 'Joes Crab Shack'
      expect(last_response.status).to eq(200)
      updated_biz = JSON.parse(last_response.body)['data']
      expect(updated_biz['name']).to eq('Joes Crab Shack')
    end
  end
  describe 'POST /businesses' do
    it 'should create a business with all the attributes' do
      post '/businesses', FactoryGirl.build(:business).attributes
      expect(last_response.status).to eq(201)
    end

    it 'should complain if any of the attributes are missing' do
      post '/businesses'
      response = JSON.parse(last_response.body)
      expect(last_response.status).to eq(400)
      errors = response['error']
      expect(errors['code']).to eq('api_error')
      %i(name address city state zip website phone waiting_period).each do |att|
        expect(errors['message']).to include("#{att} is missing")
      end
    end
  end
  describe 'GET /businesses/:id/checkins' do
    context 'when logged in' do
      before do
        user2 = FactoryGirl.create(:user)
        user = FactoryGirl.create(:user)
        business = FactoryGirl.create(:business)
        api_key = FactoryGirl.create(:api_key, user: user)
        Timecop.freeze(2.days.ago) do
          @checkin1 =  FactoryGirl.create(:checkin, user: user, business: business)
          @checkin2 =  FactoryGirl.create(:checkin, user: user2, business: business)
        end
        Timecop.freeze(1.day.ago) do
          FactoryGirl.create(:checkin, user: user, business: business)
        end
        get "/businesses/#{business.id}/checkins", api_key: api_key.access_token
      end
      it 'should return a 200 status code' do
        expect(last_response.status).to eq(200)
      end
      it 'should return the number of checkins per business for a particular user' do
        response = JSON.parse(last_response.body)
        expect(response['data']).to have(2).items
      end
    end
  end
end
