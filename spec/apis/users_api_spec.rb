require 'spec_helper'
def app
  ApplicationApi
end
describe UsersApi do
  include Rack::Test::Methods
  describe "GET /users" do
    it "will give you a list of users" do
      user = FactoryGirl.create(:user)
      get "/users"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq({ data: [ UserRepresenter.new(user) ] }.to_json)
    end
  end
  describe "GET /users/:id" do
    let(:user){FactoryGirl.create(:user)}
    context "when the user exists" do
      before do
        get "/users/#{user.id}"
      end
      it "the service will tell you they exist" do
        expect(last_response.status).to eq(200)
      end
      it "the service will tell you about the user" do
        expect(last_response.body).to eq({ data: UserRepresenter.new(user) }.to_json)
      end
    end
    context "when the user does not exist" do
      before do
        get "/users/234082342343"
      end
      it "the service will tell you the user doesnt exist" do
        expect(last_response.status).to eq(404)
      end
    end
  end
  describe "POST /users" do
    context "with the proper attributes" do
      before do
        post "/users", name: "Sam Granieri", email: "sam.granieri@gmail.com", password: "password", password_confirmation: "password"
      end
      it "should create a user" do
        expect(last_response.status).to eq(201)
      end
    end
    context "missing attributes" do
      before do
        post "/users"
      end
      it "should respond with a 400 response code" do
        expect(last_response.status).to eq(400)
      end
      it "should complain because of missing attributes" do
        response = JSON.parse(last_response.body)
        expect(response['error']['code']).to eq('api_error')
        expect(response['error']['message']).to eq('name is missing, email is missing, password is missing, password_confirmation is missing')
      end
    end
  end
  describe "PUT /users/:id" do
    context "given a user that doesnt exist" do
      it "the service will return 404" do
        put "/users/234234234", name: "DERP"
        expect(last_response.status).to eq(404)
      end
    end
    context "given a user that does exist" do
      let(:user){FactoryGirl.create(:user)}
      it "will update a user" do
        # user = FactoryGirl.create(:user)
        put "/users/#{user.id}", name: 'Joe Southport'
        expect(last_response.status).to eq(200)
        response = JSON.parse(last_response.body)
        expect(response['data']['name']).to eq('Joe Southport')
      end
      it "wont allow a user to update the password if the confirmation doesnt match" do
        put "/users/#{user.id}", password: 'joe', password_confirmation: 'pants'
        expect(last_response.status).to eq(422)
        response = JSON.parse(last_response.body)
        expect(response['error']['code']).to eq('unprocessable_entity')
        expect(response['error']['message']).to eq("Validation failed: Password confirmation doesn't match Password")
      end
    end
  end
  describe "DELETE /users/:id" do
    it "is not allowed for security reasons" do
      user = FactoryGirl.create(:user)
      delete "/users/:id"
      expect(last_response.status).to eq(405)
    end
  end
end
