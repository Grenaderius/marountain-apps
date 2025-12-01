class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :authorize_request

  private

  def authorize_request
    @current_user = User.find_by(id: session[:user_id]) if session[:user_id]

    # JWT autorize
    if request.headers['Authorization'].present?
      token = request.headers['Authorization'].split(' ').last
      decoded = JsonWebToken.decode(token) rescue nil
      @current_user ||= User.find_by(id: decoded[:user_id]) if decoded
    end

    return if @current_user

    respond_to do |format|
      format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
      format.html { redirect_to "/login" } # Для HTML запитів просто редірект без flash
    end
  end
end
