class SessionsController < ApplicationController
  skip_before_action :authorize_request, only: [:create]

  def create
    creds = params[:session] || params
    user = User.find_by(email: creds[:email])

    if user&.authenticate(creds[:password])
      token = JsonWebToken.encode({ user_id: user.id })
      render json: { user: user, token: token }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end
end
