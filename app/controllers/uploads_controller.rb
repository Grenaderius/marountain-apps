class UploadsController < ApplicationController
  before_action :authorize_request

  def create
    return render json: { error: 'No file provided' }, status: :bad_request if params[:file].blank?

    uploaded_file = params[:file]
    temp_path = uploaded_file.tempfile.path

    drive = GoogleDriveService.new
    result = drive.upload_file(
      temp_path,
      uploaded_file.original_filename,
      uploaded_file.content_type
    )

    # Тепер можна зберігати result[:view_link] або result[:download_link] в DB
    render json: {
      id: result[:id],
      webViewLink: result[:view_link],
      webContentLink: result[:download_link]
    }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
