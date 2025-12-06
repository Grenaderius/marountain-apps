class AppsController < ApplicationController
  skip_before_action :authorize_request, only: [:index, :show]
  before_action :authorize_request, only: [:create, :update, :destroy]

  def create
    drive = GoogleDriveService.new

    photo_link = nil
    apk_link = nil

    if params[:photo].present?
      uploaded_photo = params[:photo]
      result = drive.upload_file(
        uploaded_photo.tempfile.path,
        uploaded_photo.original_filename,
        uploaded_photo.content_type
      )
      photo_link = result[:view_link]
    end

    if params[:apk].present?
      uploaded_apk = params[:apk]
      result = drive.upload_file(
        uploaded_apk.tempfile.path,
        uploaded_apk.original_filename,
        uploaded_apk.content_type
      )
      apk_link = result[:view_link]
    end

    app = App.new(
      app_params.merge(
        dev_id: @current_user.id,
        photo_path: photo_link,
        apk_path: apk_link
      )
    )

    if app.save
      render json: app, status: :created
    else
      render json: { errors: app.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    apps = App.all.map do |app|
      {
        id: app.id,
        name: app.name,
        photo: app.photo_path,
        is_game: app.is_game,
        rating: app.comments.any? ? app.comments.average(:rating).to_f.round(1) : 0
      }
    end

    render json: apps
  end

  def show
    app = App.find_by(id: params[:id])

    if app
      render json: {
        id: app.id,
        name: app.name,
        description: app.description,
        photo: app.photo_path,
        apk: app.apk_path,
        is_game: app.is_game,
        cost: app.cost,
        size: app.size,
        android_min_version: app.android_min_version,
        ram_needed: app.ram_needed,
        rating: app.comments.any? ? app.comments.average(:rating).to_f.round(1) : 0
      }
    else
      render json: { error: "App not found" }, status: :not_found
    end
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
      :ram_needed
    )
  end
end
