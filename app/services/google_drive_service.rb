require 'google/apis/drive_v3'
require 'googleauth'
require 'stringio'
require 'json'

class GoogleDriveService
  DRIVE_SCOPE = 'https://www.googleapis.com/auth/drive.file'

  DEFAULT_FOLDER_ID = ENV['GOOGLE_DRIVE_FOLDER_ID']

  def initialize
    json_key = ENV['GOOGLE_SERVICE_ACCOUNT_JSON']
    raise "Missing GOOGLE_SERVICE_ACCOUNT_JSON ENV variable" unless json_key

    @auth = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(json_key),
      scope: DRIVE_SCOPE
    )
    @auth.fetch_access_token!

    @drive_service = Google::Apis::DriveV3::DriveService.new
    @drive_service.authorization = @auth
  end

  def upload_file(file_path, file_name, mime_type, folder_id = nil)
    raise "Missing GOOGLE_DRIVE_FOLDER_ID ENV variable" unless DEFAULT_FOLDER_ID

  # Перевіряємо чи існує папка
  puts ENV["GOOGLE_SERVICE_ACCOUNT_JSON"]
  puts "DEBUG: Folder ID = #{DEFAULT_FOLDER_ID}"
  begin
    @drive_service.get_file(DEFAULT_FOLDER_ID, fields: 'id')
    puts "DEBUG: Folder_exists = YES"
  rescue => e
    puts "DEBUG: Folder_exists = NO, ERROR = #{e.message}"
  end

    begin
      @drive_service.get_file(DEFAULT_FOLDER_ID, fields: 'id')
    rescue Google::Apis::ClientError
      raise "❌ Folder with ID #{DEFAULT_FOLDER_ID} does not exist!"
    end

    metadata = {
      name: file_name,
      parents: [DEFAULT_FOLDER_ID]
    }

    file = @drive_service.create_file(
      metadata,
      upload_source: file_path,
      content_type: mime_type,
      fields: 'id, webViewLink, webContentLink'
    )

    permission = Google::Apis::DriveV3::Permission.new(
      role: 'reader',
      type: 'anyone'
    )
    @drive_service.create_permission(file.id, permission)

    {
      id: file.id,
      view_link: file.web_view_link,
      download_link: file.web_content_link
    }
  rescue Google::Apis::Error => e
    puts "❌ Google API error: #{e.message}"
    raise "Drive upload failed"
  end
end
