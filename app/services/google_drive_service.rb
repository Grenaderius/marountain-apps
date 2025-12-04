require "googleauth"
require "google/apis/drive_v3"
require "googleauth/stores/memory_store"

class GoogleDriveService
  SCOPE = ["https://www.googleapis.com/auth/drive"]

  def initialize
    @client_id = Google::Auth::ClientId.new(
      ENV["CLIENT_ID"],
      ENV["CLIENT_SECRET"]
    )

    @token_store = Google::Auth::Stores::MemoryStore.new
    @user_id = "default_user"

    @token_store.store(@user_id, {
      refresh_token: ENV["REFRESH_TOKEN"],
      client_id: ENV["CLIENT_ID"],
      client_secret: ENV["CLIENT_SECRET"]
    })

    @authorizer =
      Google::Auth::UserAuthorizer.new(@client_id, SCOPE, @token_store)

    @credentials = @authorizer.get_credentials(@user_id)
    @credentials.refresh!

    @service = Google::Apis::DriveV3::DriveService.new
    @service.authorization = @credentials
  end

  def upload_file(path, file_name, mime_type, folder_id = nil)
    file_metadata = {
      name: file_name,
      parents: folder_id ? [folder_id] : nil
    }

    result = @service.create_file(
      file_metadata,
      upload_source: path,
      content_type: mime_type,
      fields: "id, webViewLink, webContentLink"
    )

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

  def delete_file(file_id)
    @service.delete_file(file_id)
  end

  def download_file(file_id, local_path)
    File.open(local_path, "wb") do |file|
      @service.get_file(file_id, download_dest: file)
    end
  end

  def list_files
    @service.list_files(fields: "files(id, name)").files
  end
end
