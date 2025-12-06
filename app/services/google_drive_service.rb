require "google/apis/drive_v3"
require "googleauth"

class GoogleDriveService
  def initialize
    @drive_service = Google::Apis::DriveV3::DriveService.new

    @drive_service.authorization = Signet::OAuth2::Client.new(
      client_id: ENV["CLIENT_ID"],
      client_secret: ENV["CLIENT_SECRET"],
      refresh_token: ENV["REFRESH_TOKEN"],
      token_credential_uri: "https://oauth2.googleapis.com/token"
    )

    @drive_service.authorization.fetch_access_token!
  end


  def upload_file(path, file_name, mime_type)
    file_metadata = {
      name: file_name  
    }

    result = @drive_service.create_file(
      file_metadata,
      upload_source: path,
      content_type: mime_type,
      fields: "id, name, web_view_link, web_content_link"
    )

    permission = Google::Apis::DriveV3::Permission.new(
      type: "anyone",
      role: "reader"
    )

    @drive_service.create_permission(result.id, permission)

    {
      id: result.id,
      view_link: result.web_view_link,
      download_link: result.web_content_link
    }
  end


  def delete_file(file_id)
    @drive_service.delete_file(file_id)
    true
  end


  def list_files
    res = @drive_service.list_files(fields: "files(id, name, web_view_link)")
    res.files
  end

  def download_file(file_id, destination)
    File.open(destination, "wb") do |file|
      @drive_service.get_file(file_id, download_dest: file)
    end
  end
end
