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
