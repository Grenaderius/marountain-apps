class UploadsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    if params[:file].blank?
      render json: { error: 'No file provided' }, status: :bad_request
      return
    end

    uploaded_file = params[:file]
    temp_path = uploaded_file.tempfile.path
    drive = GoogleDriveService.new

    result = drive.upload_file(
      temp_path,
      uploaded_file.original_filename,
      uploaded_file.content_type,
      ENV['GOOGLE_DRIVE_FOLDER_ID'] # можеш зберігати файли в певній папці
    )

    render json: {
      id: result[:id],
      webViewLink: result[:view_link],
      webContentLink: result[:download_link]
    }
  rescue => e
    Rails.logger.error("Drive upload failed: #{e.message}")
    render json: { error: 'Upload failed' }, status: :internal_server_error
  end
end
