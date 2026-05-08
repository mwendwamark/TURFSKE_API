require "cgi"
require "net/http"
require "uri"

class PaystackService
  BASE_URL = "https://api.paystack.co"

  def initialize(secret_key: ENV["PAYSTACK_SECRET_KEY"])
    @secret_key = secret_key.to_s
    raise "PAYSTACK_SECRET_KEY not found in environment variables" if @secret_key.blank?
  end

  def create_mpesa_charge(email:, amount:, phone:, reference:, metadata: {})
    request(
      :post,
      "/charge",
      email: email,
      amount: amount,
      currency: "KES",
      reference: reference,
      mobile_money: {
        phone: phone,
        provider: "mpesa"
      },
      metadata: metadata
    )
  end

  def verify_transaction(reference)
    request(:get, "/transaction/verify/#{CGI.escape(reference)}")
  end

  private

  def request(method, path, body = nil)
    uri = URI("#{BASE_URL}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 30

    request = build_request(method, uri, body)
    response = http.request(request)
    parsed_body = parse_json(response.body)

    if response.is_a?(Net::HTTPSuccess)
      parsed_body.deep_symbolize_keys
    else
      {
        status: false,
        message: parsed_body["message"] || "HTTP Error: #{response.code} #{response.message}",
        data: parsed_body["data"]
      }
    end
  rescue => e
    Rails.logger.error "PaystackService error: #{e.class}: #{e.message}"
    { status: false, message: e.message }
  end

  def build_request(method, uri, body)
    request_class = method == :post ? Net::HTTP::Post : Net::HTTP::Get
    request = request_class.new(uri)
    request["Authorization"] = "Bearer #{@secret_key}"
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"
    request.body = body.to_json if body.present?
    request
  end

  def parse_json(body)
    JSON.parse(body.presence || "{}")
  rescue JSON::ParserError
    {}
  end
end
