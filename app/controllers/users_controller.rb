class UsersController < ApplicationController
  # Повертає всіх користувачів
  def index
    users = User.all
    render json: users
  end

  # Повертає конкретного користувача за id
  def show
    user = User.find(params[:id])
    render json: user, include: :apps
  end

  # Створює нового користувача (реєстрація)
def create
  Rails.logger.info "USER PARAMS: #{user_params.inspect}"
  user = User.new(user_params)

  if user.save
    render json: { message: "User created successfully", user: user }, status: :created
  else
    render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
  end
end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
