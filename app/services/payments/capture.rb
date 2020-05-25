class Payments::Capture < Payments::Base

  include Interactor

  before do
    @order = context[:order]
  end

  def call
    payment = @order.payment

    post_data = DEFAULT_OPTIONS.merge(
        command: 'CAPTURE',
        merchant_reference: payment[:merchant_reference],
        language: I18n.locale.to_s,
        currency: 'SAR'
    )

    post_data[:amount] = (@order.global_price * 100).ceil
    post_data[:signature] = generate_signature(post_data, 'request')
    response = get_api_call(post_data, payment_service_url)
    @result = JSON.parse(response)

    if @result['response_code'].last(3) == '000'
      compare_signatures(@result)
      @order.payment.update(status: 'paid')
    end
  end


  after do
    context.result = @result
  end

end
