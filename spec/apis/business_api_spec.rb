require 'spec_helper'
def app
  ApplicationApi
end
describe BusinessesApi do
  include Rack::Test::Methods
  describe 'GET /businesses' do
    it "returns a list of all Businesses" do
      business = FactoryGirl.create(:business)
      get "/businesses"
      expect(last_response.body).to eq({data: [ BusinessRepresenter.new(business) ]}.to_json)
    end
  end
end
