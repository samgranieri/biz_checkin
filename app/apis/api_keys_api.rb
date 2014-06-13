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
    else
      error!(present_error(:invalid_login, ['email and/or password are wrong']), 403)
    end
  end

  desc 'Delete an Api Key'
  params do
    requires :access_token, type: String, desc: 'Api Key access token'
  end
  route_param :access_token do
    delete do
      api_key = ApiKey.find_by!(access_token: params[:access_token])
      api_key.destroy
      {status: 'Api Key deleted'}
    end
  end
end
