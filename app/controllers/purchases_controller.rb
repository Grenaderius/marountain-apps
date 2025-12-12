class PurchasesController < ApplicationController
  before_action :authorize_request, only: [:my, :create_after_payment]

  def my
    drive = GoogleDriveService.new

    purchases = Purchase.where(user_id: @current_user.id).includes(:app)

    apps = purchases.map do |p|
      app = p.app
      next unless app

      {
        id: app.id,
        name: app.name,
        description: app.description,
        photo_url: drive_direct_link(app.photo_path),
        apk_url: direct_download_link(app.apk_path),
        cost: app.cost,
        dev_id: app.dev_id
      }
    end.compact

    render json: apps
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def create_after_payment
    purchase = Purchase.find_or_create_by(user_id: @current_user.id, app_id: params[:app_id])
    render json: purchase
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
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
