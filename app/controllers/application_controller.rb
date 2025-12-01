class ApplicationController < ActionController::API
  before_action :authorize_request

  private

  def authorize_request
    @current_user = nil

    # JWT авторизація
    if request.headers['Authorization'].present?
      token = request.headers['Authorization'].split(' ').last
      decoded = JsonWebToken.decode(token) rescue nil
      @current_user = User.find_by(id: decoded[:user_id]) if decoded
    end

    return if @current_user

    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
