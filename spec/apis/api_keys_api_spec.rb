require 'spec_helper'
def app
  ApplicationApi
end

describe "ApiKeysApi" do
  include Rack::Test::Methods
  describe "POST /api_keys" do
    context "with a username and password" do
      it "should create an api key" do
        user = FactoryGirl.create(:user)
        expect{
          post "/api_keys", email: user.email, password: user.password
        }.to change{ApiKey.count}.by(1)
      end
    end
  end
end
