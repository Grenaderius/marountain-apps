class UsersController < ApplicationController
  skip_before_action :authorize_request, only: [:create, :show, :index]

  def index
    render json: User.all
  end

  def show
    user = User.find(params[:id])
    render json: user, include: :apps
  end

  def create
    user = User.new(user_params)
    if user.save
      token = JsonWebToken.encode(user_id: user.id)
      render json: { token: token }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end