class GoogleDriveController < ApplicationController
  def upload
    file = params[:file]

    service = GoogleDriveService.new

    result = service.upload_file(
      file.tempfile.path,
      file.original_filename,
      file.content_type
    )

    render json: { id: result.id }
  end

  def delete
    service = GoogleDriveService.new
    service.delete_file(params[:id])
    render json: { deleted: true }
  end

  def list
    service = GoogleDriveService.new
    files = service.list_files
    render json: files
  end

  def download
    file_id = params[:id]

    service = GoogleDriveService.new

    # тимчасовий файл
    temp_path = Rails.root.join("tmp", "#{file_id}.downloaded")

    # завантажити файл локально
    service.download_file(file_id, temp_path.to_s)

    send_file temp_path, disposition: "attachment"
  end

end
