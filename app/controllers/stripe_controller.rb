class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authorize_request

  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError
      return render json: { error: 'Invalid payload' }, status: 400
    rescue Stripe::SignatureVerificationError
      return render json: { error: 'Invalid signature' }, status: 400
    end

    case event['type']
    when 'checkout.session.completed'
      session = event['data']['object']

      user_id = session['metadata']['user_id'].to_i
      app_id = session['metadata']['app_id'].to_i

      Purchase.find_or_create_by(user_id:, app_id:)
    end

    render json: { status: 'success' }
  end
end
