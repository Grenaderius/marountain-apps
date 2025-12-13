class ApplicationController < ActionController::API
  before_action :authorize_request

  private

  def authorize_request
    header = request.headers['Authorization']

    if header.present?
      token = header.split(' ').last
      decoded = JsonWebToken.decode(token)
      @current_user = User.find(decoded[:user_id])
    else
      @current_user = nil
    end

  rescue JWT::DecodeError
    render json: { errors: ['Invalid token'] }, status: :unauthorized
  end
end
