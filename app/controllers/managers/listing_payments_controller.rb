module Managers
  class ListingPaymentsController < ApplicationController
    before_action :authenticate_manager!

    LISTING_FEE_KES = BigDecimal(ENV.fetch("PAYSTACK_LISTING_FEE_KES", "1"))
    CURRENCY = "KES"

    # POST /managers/listing_payments
    def create
      phone = normalize_kenyan_phone(params[:phone_number])
      return render json: { error: "Enter a valid Kenyan M-PESA phone number." }, status: :unprocessable_entity if phone.blank?

      payment = current_user.payments.create!(
        payment_type: "listing_fee",
        amount_kobo: listing_fee_subunit,
        currency: CURRENCY,
        paystack_reference: listing_reference,
        channel: "mobile_money",
        status: "pending"
      )

      response = PaystackService.new.create_mpesa_charge(
        email: current_user.email,
        amount: payment.amount_kobo,
        phone: phone,
        reference: payment.paystack_reference,
        metadata: {
          payment_type: payment.payment_type,
          user_id: current_user.id
        }
      )

      if response[:status]
        update_payment_from_paystack!(payment, response[:data] || {}, response)
        render json: payment_json(payment.reload, response[:data]), status: :created
      else
        payment.update!(status: "failed", paystack_metadata: response)
        render json: { error: response[:message] || "Unable to initiate listing payment." }, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error "Listing payment create error: #{e.class}: #{e.message}"
      render json: { error: e.message }, status: :unprocessable_entity
    end

    # GET /managers/listing_payments/:reference
    def show
      payment = current_user.payments.listing_fee.find_by!(paystack_reference: params[:reference])
      verify_payment!(payment) unless payment.successful? || payment.status == "failed"

      render json: payment_json(payment.reload), status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Listing payment not found." }, status: :not_found
    rescue => e
      Rails.logger.error "Listing payment status error: #{e.class}: #{e.message}"
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def listing_reference
      "LISTING_#{current_user.id}_#{SecureRandom.hex(8)}"
    end

    def listing_fee_subunit
      (LISTING_FEE_KES * 100).to_i
    end

    def normalize_kenyan_phone(raw_phone)
      digits = raw_phone.to_s.gsub(/[^\d+]/, "")
      digits = digits.sub(/\A0/, "+254")
      digits = "+#{digits}" if digits.start_with?("254")
      return digits if digits.match?(/\A\+254\d{9}\z/)

      nil
    end

    def verify_payment!(payment)
      response = PaystackService.new.verify_transaction(payment.paystack_reference)
      return payment.update!(paystack_metadata: response) unless response[:status]

      update_payment_from_paystack!(payment, response[:data] || {}, response)
    end

    def update_payment_from_paystack!(payment, data, raw_response)
      paystack_status = data[:status].to_s
      internal_status = case paystack_status
      when "success" then "success"
      when "failed", "abandoned", "timeout", "reversed" then "failed"
      else "pending"
      end

      payment.update!(
        status: internal_status,
        paystack_transaction_id: data[:id].presence || payment.paystack_transaction_id,
        channel: data[:channel].presence || payment.channel,
        paid_at: data[:paid_at].presence || payment.paid_at,
        paystack_metadata: raw_response
      )
    end

    def payment_json(payment, paystack_data = nil)
      {
        reference: payment.paystack_reference,
        status: payment.status,
        amount_kes: payment.amount_kobo.to_i / 100.0,
        currency: payment.currency,
        display_text: paystack_data&.dig(:display_text),
        message: paystack_data&.dig(:message)
      }
    end
  end
end
