class AuthController < ApplicationController
  skip_before_action :authorize_request

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      session[:user_id] = user.id
      render json: { token: token, user: { id: user.id, email: user.email } }
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end
end