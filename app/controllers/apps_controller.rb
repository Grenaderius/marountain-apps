class AppsController < ApplicationController
  skip_before_action :authorize_request, only: [:index, :show]
  before_action :authorize_request, only: [:create, :update, :destroy, :my]

  def create
    drive = GoogleDriveService.new

    photo_link = params[:photo].present? ? drive.upload_file(
      params[:photo].tempfile.path,
      params[:photo].original_filename,
      params[:photo].content_type
    )[:view_link] : nil

    apk_link = params[:apk].present? ? drive.upload_file(
      params[:apk].tempfile.path,
      params[:apk].original_filename,
      params[:apk].content_type
    )[:view_link] : nil

    app = App.new(app_params.merge(
      dev_id: @current_user.id,
      photo_path: photo_link,
      apk_path: apk_link
    ))

    if app.save
      render json: app, status: :created
    else
      render json: { errors: app.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    app = App.find(params[:id])

    unless app.dev_id == @current_user.id
      return render json: { error: "Forbidden" }, status: :forbidden
    end

    drive = GoogleDriveService.new

    if params[:photo].present?
      photo_link = drive.upload_file(
        params[:photo].tempfile.path,
        params[:photo].original_filename,
        params[:photo].content_type
      )[:view_link]
      app.photo_path = photo_link
    end

    if params[:apk].present?
      apk_link = drive.upload_file(
        params[:apk].tempfile.path,
        params[:apk].original_filename,
        params[:apk].content_type
      )[:view_link]
      app.apk_path = apk_link
    end

    updatable_fields = {}
    updatable_fields[:name] = params[:app][:name].strip if params[:app][:name].present? && params[:app][:name].strip != ""
    updatable_fields[:description] = params[:app][:description].strip if params[:app][:description].present? && params[:app][:description].strip != ""
    updatable_fields[:cost] = params[:app][:cost] if params[:app][:cost].present?
    updatable_fields[:size] = params[:app][:size] if params[:app][:size].present?
    updatable_fields[:android_min_version] = params[:app][:android_min_version] if params[:app][:android_min_version].present?
    updatable_fields[:ram_needed] = params[:app][:ram_needed] if params[:app][:ram_needed].present?
    updatable_fields[:is_game] = params[:app][:is_game] unless params[:app][:is_game].nil? # checkbox може бути false

    if app.update(updatable_fields)
      render json: app
    else
      render json: { errors: app.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def my
    drive = GoogleDriveService.new
    apps = App.where(dev_id: @current_user.id).map do |app|
      {
        id: app.id,
        name: app.name,
        photo_url: app.photo_path.present? ? drive_direct_link(app.photo_path) : nil,
        is_game: app.is_game,
        rating: app.comments.any? ? app.comments.average(:rating).to_f.round(1) : 0
      }
    end

    render json: apps
  end

  def index
    drive = GoogleDriveService.new
    apps = App.all.map do |app|
      {
        id: app.id,
        name: app.name,
        dev_id: app.dev_id,
        photo_url: drive_direct_link(app.photo_path),
        is_game: app.is_game,
        rating: app.comments.any? ? app.comments.average(:rating).to_f.round(1) : 0
      }
    end

    render json: apps
  end

  def show
    app = App.find_by(id: params[:id])

    unless app
      return render json: { error: "App not found" }, status: :not_found
    end

    render json: {
      id: app.id,
      name: app.name,
      description: app.description,
      photo_url: drive_direct_link(app.photo_path),
      apk_file_id: app.apk_path,
      is_game: app.is_game,
      cost: app.cost,
      size: app.size,
      android_min_version: app.android_min_version,
      ram_needed: app.ram_needed,
      rating: app.comments.any? ? app.comments.average(:rating).to_f.round(1) : 0,
      dev: app.dev ? { id: app.dev.id, email: app.dev.email } : nil
    }
  end

  def destroy
    app = App.find_by(id: params[:id])

    unless app
      return render json: { error: "App not found" }, status: :not_found
    end

    unless app.dev_id == @current_user.id
      return render json: { error: "Forbidden" }, status: :forbidden
    end

    app.destroy
    render json: { message: "App deleted successfully" }, status: :ok
  end

  def drive_direct_link(url)
    return nil unless url
    match = url.match(/\/d\/([a-zA-Z0-9_-]+)/)
    return nil unless match

    file_id = match[1]
    "https://drive.google.com/thumbnail?id=#{file_id}&sz=w500"
  end

  private

  def app_params
    params.require(:app).permit(
      :name, :description, :is_game, :cost, :size,
      :android_min_version, :ram_needed
    )
  end
end
