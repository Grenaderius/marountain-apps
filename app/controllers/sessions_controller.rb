class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    creds = params[:session] || params
    user = User.find_by(email: creds[:email])

    if user&.authenticate(creds[:password])
      render json: { user: user }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end
end
