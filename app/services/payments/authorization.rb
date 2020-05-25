class Payments::Authorization < Payments::Base

  include Interactor

  before do
    @params = context[:params]
    @order = context[:order]
  end

  def call
    payment = @order.payment

    post_data = DEFAULT_OPTIONS.merge(
        merchant_reference: payment[:merchant_reference],
        command: 'AUTHORIZATION',
        currency: 'SAR',
        customer_ip: payment[:ip_address] || '127.0.0.1',
        customer_email: @order.buyer.email,
        customer_name: @order.buyer.name,
        token_name: payment[:token],
        language: I18n.locale.to_s,
        eci: 'ECOMMERCE',
        remember_me: 'NO',
        return_url: Rails.configuration.front_end_url + "/api/v1/payments/callback?order=#{@order.id}&r=authorization_response"
    )
    post_data[:amount] = (@order.global_price * 100).ceil
    post_data[:signature] = generate_signature(post_data, 'request')
    response = get_api_call(post_data, payment_service_url)
    @result = JSON.parse(response)
  end

  
  after do
    context.result = @result
  end

end
