class AuthApi < Grape::API
  helpers Authentication

  desc 'Login'
  params do
    requires :email, type: String, desc: 'User email'
    requires :password, type: String, desc: 'User password'
  end
  post :login do
    user = User.find_by!(email: params[:email])
    if user && user.authenticate(params[:password])
      if user.api_key
        { api_key: user.api_key.access_token }
      else
        api_key = ApiKey.create(user: user)
        { api_key: api_key.access_token }
      end
    else
      error!('Unauthorized!', 401)
    end
  end
  desc 'Logout'
  params do
    requires :api_key, type: String, desc: 'Api Key'
  end
  delete :logout do
    authenticate!
    @current_user.api_key.destroy
    status 204
  end
end
