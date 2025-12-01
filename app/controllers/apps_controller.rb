class AppsController < ApplicationController
  before_action :authorize_request, only: [:create, :update, :destroy]

  def index
    apps = App.all.includes(:comments)

    result = apps.map do |app|
      {
        id: app.id,
        name: app.name,
        is_game: app.is_game,
        photo: app.photo_path,
        rating: app.comments.any? ? app.comments.average(:rating).to_f.round(1) : 0,
        dev_id: app.dev_id
      }
    end

    render json: result
  end

  def show
    app = App.includes(comments: :user).find(params[:id])
    render json: app, include: {
      comments: { include: { user: { only: [:id, :email, :name] } } }
    }
  end

  def create
    app = App.new(app_params.merge(dev_id: @current_user.id))

    if app.save
      render json: app, status: :created
    else
      render json: { errors: app.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    app = App.find(params[:id])

    return render json: { error: "Not allowed" }, status: :forbidden unless app.dev_id == @current_user.id

    if app.update(app_params)
      render json: app
    else
      render json: { errors: app.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    app = App.find(params[:id])

    return render json: { error: "Not allowed" }, status: :forbidden unless app.dev_id == @current_user.id

    app.destroy
    head :no_content
  end

  private

  def app_params
    params.require(:app).permit(
      :name,
      :description,
      :is_game,
      :cost,
      :size,
      :android_min_version,
      :ram_needed,
      :photo_path,
      :apk_path
    )
  end
end
