require 'rails_helper'

RSpec.describe Payments::Authorization do
  describe '.call' do

    let(:order) { create(:order, :with_payment) }

    before { allow(Payments::Authorization).to receive(:call).and_call_original }

    before(:each) do

      stub_request(:post, 'https://sbpaymentservices.payfort.com/FortAPI/paymentApi').
          with(body: {access_code: 'wzBTueYAgOw1eD9Msp6m',
                      merchant_identifier: 'TMclWFPP',
                      merchant_reference: order.payment.merchant_reference,
                      command: 'AUTHORIZATION',
                      currency: 'SAR',
                      customer_ip: '127.0.0.1',
                      customer_email: order.buyer.email,
                      customer_name: order.buyer.name,
                      token_name: order.payment.token,
                      language: 'en',
                      eci: 'ECOMMERCE',
                      remember_me: 'NO',
                      return_url: "https://api.staging.foodinhoods.com/api/v1/payments/callback?order=#{order.id}&r=authorization_response",
                      amount: (order.global_price * 100).ceil,
                      signature: authorization_signature(order)
          }.to_json
          ).to_return(body: AUTHORIZATION_RESPONSE.to_json)
    end


    it 'generate request' do
      result = Payments::Authorization.call(order: order)
      expect(result).to be_a_success
      expect(a_request(:post, 'https://sbpaymentservices.payfort.com/FortAPI/paymentApi')).to have_been_made.once
    end


    it 'when PAYMENT_SANDBOX_MODE false another URL' do

      ENV['PAYMENT_SANDBOX_MODE'] = 'false'

      stub_request(:post, 'https://paymentservices.payfort.com/FortAPI/paymentApi').
          to_return(body: AUTHORIZATION_RESPONSE.to_json)


      result = Payments::Authorization.call(order: order)
      expect(result).to be_a_success
      expect(a_request(:post, 'https://paymentservices.payfort.com/FortAPI/paymentApi')).to have_been_made.once
      ENV['PAYMENT_SANDBOX_MODE'] = 'true'
    end


  end

end



