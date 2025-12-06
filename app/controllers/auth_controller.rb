class AuthController < ApplicationController
  skip_before_action :authorize_request, only: [:login]
  
  def login
    user = User.find_by(email: params[:session][:email])
    if user&.authenticate(params[:session][:password])
        token = JsonWebToken.encode(user_id: user.id)
        render json: { token: token, user: { id: user.id, email: user.email } }, status: :ok
    else
        render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end
end