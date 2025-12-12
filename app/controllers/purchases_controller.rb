class PurchasesController < ApplicationController
    skip_before_action :authorize_request

  def my
    drive = GoogleDriveService.new

    purchases = Purchase.where(user_id: @current_user.id).includes(:app)

    apps = purchases.map do |p|
      app = p.app

      {
        id: app.id,
        name: app.name,
        description: app.description,
        photo_url: drive_direct_link(app.photo_path),
        apk_url: direct_download_link(app.apk_path),
        cost: app.cost,
        dev_id: app.dev_id
      }
    end

    render json: apps
  end

  private

  def drive_direct_link(url)
    return nil unless url
    match = url.match(/\/d\/([a-zA-Z0-9_-]+)/)
    return nil unless match

    file_id = match[1]
    "https://drive.google.com/thumbnail?id=#{file_id}&sz=w500"
  end

  def direct_download_link(url)
    return nil unless url
    match = url.match(/\/d\/([a-zA-Z0-9_-]+)/)
    return nil unless match

    file_id = match[1]
    "https://drive.google.com/uc?export=download&id=#{file_id}"
  end
end
