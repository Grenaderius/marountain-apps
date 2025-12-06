require "google/apis/drive_v3"
require "googleauth"

class GoogleDriveService
  def initialize
    @service = Google::Apis::DriveV3::DriveService.new

    @service.authorization = Signet::OAuth2::Client.new(
      client_id: ENV["CLIENT_ID"],
      client_secret: ENV["CLIENT_SECRET"],
      refresh_token: ENV["REFRESH_TOKEN"],
      token_credential_uri: "https://oauth2.googleapis.com/token"
    )

    # оновлюємо access_token
    @service.authorization.fetch_access_token!
  end

  def upload_file(path, file_name, mime_type)
    file_metadata = {
      name: file_name,
      parents: [ENV["FOLDER_ID"]]   # зберігати в конкретну папку
    }

    result = @service.create_file(
      file_metadata,
      upload_source: path,
      content_type: mime_type,
      fields: "id, webViewLink, webContentLink"
    )

    # робимо публічним
    permission = Google::Apis::DriveV3::Permission.new(
      type: "anyone",
      role: "reader"
    )
    @service.create_permission(result.id, permission)

    {
      id: result.id,
      view_link: result.webViewLink,
      download_link: result.webContentLink
    }
  end
end
