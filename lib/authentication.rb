module Authentication
  def authenticate!
    error!('Unauthorized. Invalid or expired api key.', 401) unless current_user
  end

  def current_user
    token = ApiKey.where(access_token: params[:api_key]).first
    if token && !token.expired?
      @current_user = User.find(token.user_id)
    else
      false
    end
  end
end
