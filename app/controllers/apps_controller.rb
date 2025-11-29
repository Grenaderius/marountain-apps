class AppsController < ApplicationController
  # GET /apps
  def index
    apps = App.all.includes(:comments)

    result = apps.map do |app|
      {
        id: app.id,
        name: app.name,
        photo: app.photo_path,
        rating: app.comments.any? ? app.comments.average(:rating).to_f.round(1) : 0
      }
    end

    render json: result
  end

  # GET /apps/:id
  def show
    app = App.includes(comments: :user).find(params[:id])
    render json: app, include: {
      comments: { include: { user: { only: [:id, :email, :name] } } }
    }
  end

  # POST /apps
  def create
    app = App.new(app_params)
    if app.save
      render json: app, status: :created
    else
      render json: { errors: app.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /apps/:id
  def update
    app = App.find(params[:id])
    if app.update(app_params)
      render json: app
    else
      render json: { errors: app.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /apps/:id
  def destroy
    App.find(params[:id]).destroy
    head :no_content
  end

  private

  def app_params
    params.require(:app).permit(
      :name,
      :description,
      :is_game,
      :dev_id,
      :cost,
      :size,
      :android_min_version,
      :ram_needed,
      :photo_path,
      :apk_path,
      :downloads_count
    )
  end
end
