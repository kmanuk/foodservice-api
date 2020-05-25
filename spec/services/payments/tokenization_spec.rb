require 'rails_helper'

RSpec.describe Payments::Tokenization do
  describe '.call' do
    before { allow(Payments::Tokenization).to receive(:call).and_call_original }

    it 'generate form' do
      result = Payments::Tokenization.call
      expect(result).to be_a_success
      expect(result.form).to include("name=\"payfort_payment_form\"")
      expect(result.form).to include('https://sbcheckout.payfort.com/FortAPI/paymentPage')
      expect(result.form).to include('TOKENIZATION')
      expect(result.form).to include('/api/v1/payments/callback?r=tokenization_response')
    end


    it 'has another URL for production server' do
      ENV['PAYMENT_SANDBOX_MODE'] = 'false'
      result = Payments::Tokenization.call
      expect(result).to be_a_success
      expect(result.form).to include('https://checkout.payfort.com/FortAPI/paymentPage')
      ENV['PAYMENT_SANDBOX_MODE'] = 'true'
    end


  end

end
