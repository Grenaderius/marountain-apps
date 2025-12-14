class SessionsController < ApplicationController

  def create
    creds = params[:session] || params
    user = User.find_by(email: creds[:email])

    if user&.authenticate(creds[:password])
      token = JsonWebToken.encode({ user_id: user.id })
      session[:user_id] = user.id
      render json: { user: user, token: token }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def destroy
    session[:user_id] = nil
    render json: { message: "Logged out" }
  end
end