# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
  skip_before_action :authorize_request, only: [:create_checkout_session]

  def create_checkout_session
    app = App.find(params[:app_id])
    user_id = params[:user_id].to_i

    # Free app → no Stripe
    if app.cost.to_f <= 0
      Purchase.find_or_create_by(user_id: user_id, app_id: app.id)
      return render json: {
        free: true,
        download_url: app.apk_path
      }
    end

    session = Stripe::Checkout::Session.create(
      mode: 'payment',
      payment_method_types: ['card'],
      metadata: {
        user_id: user_id,
        app_id: app.id
      },
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: { name: app.name },
          unit_amount: (app.cost.to_f * 100).to_i
        },
        quantity: 1
      }],
      success_url: "#{ENV['DOMAIN']}/payment-success", #?session_id={CHECKOUT_SESSION_ID}
      cancel_url: "#{ENV['DOMAIN']}/"
    )

    render json: { url: session.url }
  end
end