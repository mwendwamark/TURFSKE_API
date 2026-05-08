class PaystackWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  # POST /paystack/webhook
  def create
    raw_body = request.raw_post
    return head :bad_request unless valid_signature?(raw_body)

    payload = JSON.parse(raw_body)
    process_event(payload)

    head :ok
  rescue JSON::ParserError
    head :bad_request
  rescue => e
    Rails.logger.error "Paystack webhook error: #{e.class}: #{e.message}"
    head :ok
  end

  private

  def valid_signature?(raw_body)
    signature = request.headers["x-paystack-signature"].to_s
    secret = ENV["PAYSTACK_SECRET_KEY"].to_s
    return false if signature.blank? || secret.blank?

    expected = OpenSSL::HMAC.hexdigest("SHA512", secret, raw_body)
    return false unless expected.bytesize == signature.bytesize

    ActiveSupport::SecurityUtils.secure_compare(expected, signature)
  end

  def process_event(payload)
    data = payload["data"] || {}
    reference = data["reference"].to_s
    payment = Payment.find_by(paystack_reference: reference)
    return if payment.blank?

    case payload["event"]
    when "charge.success"
      return unless valid_paid_amount?(payment, data)

      payment.update!(
        status: "success",
        paystack_transaction_id: data["id"].presence || payment.paystack_transaction_id,
        channel: data["channel"].presence || payment.channel,
        paid_at: data["paid_at"].presence || payment.paid_at,
        paystack_metadata: payload
      )
    when "charge.failed", "charge.abandoned"
      payment.update!(
        status: "failed",
        channel: data["channel"].presence || payment.channel,
        paystack_metadata: payload
      )
    end
  end

  def valid_paid_amount?(payment, data)
    data["status"] == "success" &&
      data["currency"].to_s == payment.currency &&
      data["amount"].to_i == payment.amount_kobo.to_i
  end
end
