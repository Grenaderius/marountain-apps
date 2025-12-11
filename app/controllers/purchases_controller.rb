# app/controllers/purchases_controller.rb
class PurchasesController < ApplicationController
  before_action :authorize_request

  def my
    drive = GoogleDriveService.new

    purchased_apps = @current_user.bought_apps.map do |app|
      {
        id: app.id,
        name: app.name,
        photo_url: drive_direct_link(app.photo_path),
        apk_url: app.apk_path
      }
    end

    render json: purchased_apps
  end

  private

  def drive_direct_link(url)
    return nil unless url
    match = url.match(/\/d\/([a-zA-Z0-9_-]+)/)
    return nil unless match

    file_id = match[1]
    "https://drive.google.com/thumbnail?id=#{file_id}&sz=w500"
  end
end
