class PurchasesController < ApplicationController
  before_action :authorize_request, only: [:my, :create_after_payment]

  def my
    purchases = Purchase
      .where(user_id: @current_user.id)
      .includes(:app)

    apps = purchases.map do |p|
      app = p.app
      next unless app

      {
        id: app.id,
        name: app.name,
        description: app.description,
        photo_url: drive_thumbnail(app.photo_path),
        apk_url: drive_download(app.apk_path),
        cost: app.cost,
        dev_id: app.dev_id
      }
    end.compact

    render json: apps
  end

  def create_after_payment
    app_id = params[:app_id]
    payment_success = params[:payment_success]

    return render json: { error: "app_id missing" }, status: :bad_request unless app_id

    app = App.find_by(id: app_id)
    return render json: { error: "App not found" }, status: :not_found unless app

    if app.cost.to_f > 0 && payment_success != true
      return render json: { error: "Payment not confirmed" }, status: :payment_required
    end

    purchase = Purchase.find_or_create_by!(
      user_id: @current_user.id,
      app_id: app.id
    )

    render json: purchase, status: :created
  end

  private

  def drive_thumbnail(url)
    return nil unless url
    match = url.match(/\/d\/([a-zA-Z0-9_-]+)/)
    return nil unless match
    "https://drive.google.com/thumbnail?id=#{match[1]}&sz=w500"
  end

  def drive_download(url)
    return nil unless url
    match = url.match(/\/d\/([a-zA-Z0-9_-]+)/)
    return nil unless match
    "https://drive.google.com/uc?export=download&id=#{match[1]}"
  end
end
