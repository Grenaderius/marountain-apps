class PaymentsController < ApplicationController
  skip_before_action :authorize_request, only: [:create_checkout_session, :success]

  def create_checkout_session
    app = App.find(params[:app_id])
    user_id = params[:user_id].to_i

    if app.cost.to_f <= 0
      Purchase.find_or_create_by(user_id: user_id, app_id: app.id)
      return render json: {
        free: true,
        download_url: app.apk_path
      }
    end

    session = Stripe::Checkout::Session.create(
      mode: "payment",
      payment_method_types: ["card"],
      metadata: {
        user_id: user_id,
        app_id: app.id
      },
      line_items: [{
        price_data: {
          currency: "usd",
          product_data: { name: app.name },
          unit_amount: (app.cost.to_f * 100).to_i
        },
        quantity: 1
      }],

      success_url: "#{ENV['DOMAIN']}/purchased-apps?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "#{ENV['DOMAIN']}/games"
    )

    render json: { url: session.url }
  end

  def success
    session_id = params[:session_id]
    return render json: { error: "missing session_id" }, status: 400 unless session_id

    session = Stripe::Checkout::Session.retrieve(session_id)

    user_id = session.metadata.user_id
    app_id  = session.metadata.app_id

    purchase = Purchase.find_or_create_by(
      user_id: user_id,
      app_id: app_id
    )

    render json: { ok: true, purchase: purchase }
  end
end
