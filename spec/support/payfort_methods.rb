module Payfort
  module Signature


    def authorization_signature(order)
      params = {
          access_code: ENV['ACCESS_CODE'],
          merchant_identifier: ENV['MERCHANT_IDENTIFIER'],
          merchant_reference: order.payment[:merchant_reference],
          command: 'AUTHORIZATION',
          currency: 'SAR',
          customer_ip: order.payment[:ip_address] || '127.0.0.1',
          customer_email: order.buyer.email,
          customer_name: order.buyer.name,
          token_name: order.payment[:token],
          language: 'en',
          eci: 'ECOMMERCE',
          remember_me: 'NO',
          amount: (order.global_price * 100).ceil,
          return_url: Rails.configuration.front_end_url + "/api/v1/payments/callback?order=#{order.id}&r=authorization_response"
      }

      generate_signature(params, sign_type = 'request')

    end

    def generate_signature(params, sign_type = 'request')
      sha_phrase = sign_type == 'request' ? ENV['SHA_REQUEST_PHRASE'] : ENV['SHA_RESPONSE_PHRASE']
      sha_string = params.sort.to_h.map { |k, v| "#{k}=#{v}" }.join('')

      sha_string = sha_phrase + sha_string + sha_phrase
      Digest::SHA2.new(512).hexdigest(sha_string)
    end

  end
end