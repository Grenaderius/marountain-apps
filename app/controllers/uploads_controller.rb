class UploadsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authorize_request

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
      ENV['GOOGLE_DRIVE_FOLDER_ID']
    )

    render json: {
      id: result[:id],
      webViewLink: result[:view_link],
      webContentLink: result[:download_link]
    }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
end