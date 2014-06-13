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
    let(:business){FactoryGirl.create(:business)}
    context 'when logged in' do
      before do
        user2 = FactoryGirl.create(:user)
        user = FactoryGirl.create(:user)
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
    context 'when not logged in' do
      before do
        get "/businesses/#{business.id}/checkins"
      end
      it "should return an error code of 400" do
        expect(last_response.status).to eq(400)
      end
      it "should tell you that the api_key is missing" do
        response = JSON.parse(last_response.body)
        expect(response['error']['code']).to eq('api_error')
        expect(response['error']['message']).to eq('api_key is missing')
      end
    end
  end
  describe 'POST /businesses/:id/checkins' do
    let(:business){FactoryGirl.create(:business)}
    let(:user){FactoryGirl.create(:user)}
    let(:api_key){FactoryGirl.create(:api_key, user: user)}
    context "without providing an api_key" do
      before do
        post "/businesses/#{business.id}/checkins"
      end
      it "should return 400" do
        expect(last_response.status).to eq(400)
      end
    end
    context "with providing an incorrect api_key" do
      before do
        post "/businesses/#{business.id}/checkins", api_key: 'derpderpder'
      end
      it "should return a 401" do
        expect(last_response.status).to eq(401)
      end
      it "tell you of an unauthorized or invalid token" do
        response = JSON.parse(last_response.body)
        expect(response['error']['code']).to eq('api_error')
        expect(response['error']['message']).to eq('Unauthorized. Invalid or expired api key.')
      end
    end
    context "with providing an correct api key and an incorrect business id " do
      before do
        post "/businesses/#{business.id + 50}/checkins", api_key: api_key.access_token
      end
      it "should complain with a 404 error" do
        expect(last_response.status).to eq(404)
      end
      it "should warn you that it cant find a business" do
        response = JSON.parse(last_response.body)
        expect(response['error']['code']).to eq("record_not_found")
        expect(response['error']['message']).to eq("record not found")
      end
    end
    context "with providing a proper api key and the proper business id" do
      context "for one checkin" do
        before do
          post "/businesses/#{business.id}/checkins", api_key: api_key.access_token
        end
        it "should create a checkin for that business" do
          expect(last_response.status).to eq(201)
        end
      end
    end
    context "for multiple checkins for a business with a 30 minute waiting period" do
      before do
        Timecop.travel(10.minutes.ago) do
          post "/businesses/#{business.id}/checkins", api_key: api_key.access_token
        end
        post "/businesses/#{business.id}/checkins", api_key: api_key.access_token
      end
      it "should respond with a 422 error code" do
        #I'm using Twitter's enhance your calm, since a 500 means an application error
        expect(last_response.status).to eq(422)
      end
      it "should tell you to wait" do
        response = JSON.parse(last_response.body)
        expect(response['error']['code']).to eq('record_invalid')
        expect(response['error']['message']).to include('user checked in too soon')
      end
    end
  end
end
