class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      return head 400
    end

    case event['type']
    when 'checkout.session.completed'
      session = event['data']['object']
      user_id = session.metadata.user_id
      app_id  = session.metadata.app_id

      Purchase.find_or_create_by(user_id: user_id, app_id: app_id)
    end

    head 200
  end
end
