class PaymentsController < ApplicationController
  skip_before_action :authorize_request

  def create_checkout_session
    app = App.find(params[:app_id])

    # Якщо app.cost == 0 → безкоштовно
    if app.cost.to_i == 0
      render json: {
        free: true,
        download_url: app.apk_path # або drive_direct_link(app.apk_path)
      }
      return
    end

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      mode: 'payment',
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: app.name
          },
          unit_amount: (app.cost * 100).to_i
        },
        quantity: 1
      }],
      success_url: "#{ENV['DOMAIN']}/payment-success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "#{ENV['DOMAIN']}/payment-cancel"
    )

    render json: { url: session.url }
  end
end
