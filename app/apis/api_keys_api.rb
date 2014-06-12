class ApiKeysApi < Grape::API
  desc 'Create an api_key'
  params do
    requires :email, type: String, desc: "User's email address"
    requires :password, type: String, desc: "User's Password"
  end

  post do
    user = User.where(email: params[:email]).first
    if user && user.authenticate(params[:password])
      api_key = ApiKey.create(user: user)
      error!(present_error(:record_invalid, api_key.errors.full_messages)) unless api_key.errors.empty?
      represent api_key, with: ApiKeyRepresenter
    end
  end
end
