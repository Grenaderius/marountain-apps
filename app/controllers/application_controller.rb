class ApplicationController < ActionController::API
  def authorize_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    decoded = JsonWebToken.decode(token)

    if decoded
      @current_user = User.find_by(id: decoded[:user_id])
      return render json: { error: "User not found" }, status: :unauthorized unless @current_user
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
