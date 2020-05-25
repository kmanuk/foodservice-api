class Payments::Base

  private

  DEFAULT_OPTIONS = {
      access_code: ENV['ACCESS_CODE'],
      merchant_identifier: ENV['MERCHANT_IDENTIFIER']
  }

  def compare_signatures(params)
    params_for_signature = params.except('signature', 'order', 'r')
    response_signature = params['signature']
    calculated_signature = generate_signature(params_for_signature, 'response')

    if response_signature != calculated_signature
      pp "Invalid Signature. Calculated Signature: #{calculated_signature}, Response Signature: #{response_signature}"
      context.fail!(errors: 'Invalid signature')
    end
  end

  def get_api_call(params, url)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
    req.body = params.to_json
    response = http.request(req)
    response.body
  end

  def checkout_url
    if ENV['PAYMENT_SANDBOX_MODE'] == 'true'
      'https://sbcheckout.payfort.com/FortAPI/paymentPage'
    else
      'https://checkout.payfort.com/FortAPI/paymentPage'
    end
  end

  def payment_service_url
    if ENV['PAYMENT_SANDBOX_MODE'] == 'true'
      'https://sbpaymentservices.payfort.com/FortAPI/paymentApi'
    else
      'https://paymentservices.payfort.com/FortAPI/paymentApi'
    end
  end


  def generate_merchant_reference
    Array.new(16) { rand(36).to_s(36) }.join
  end

  def generate_signature(params, sign_type = 'request')
    sha_phrase = sign_type == 'request' ? ENV['SHA_REQUEST_PHRASE'] : ENV['SHA_RESPONSE_PHRASE']
    sha_string = params.sort.to_h.map { |k, v| "#{k}=#{v}" }.join('')

    sha_string = sha_phrase + sha_string + sha_phrase
    Digest::SHA2.new(512).hexdigest(sha_string)
  end


end
