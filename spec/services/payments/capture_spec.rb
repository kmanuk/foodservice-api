require 'rails_helper'

RSpec.describe Payments::Capture do
  describe '.call' do
    before { allow(Payments::Capture).to receive(:call).and_call_original }

    before(:each) do
      stub_request(:post, 'https://sbpaymentservices.payfort.com/FortAPI/paymentApi').to_return(
          body: CAPTURE_SUCCESS_RESPONSE.to_json
      )
    end

    context 'Capture request' do
      let(:order) { create(:order, :with_payment) }
      it 'change status of the payment to paid' do
        result = Payments::Capture.call(order: order)
        expect(result).to be_a_success
        expect(order.reload.payment.status).to eq('paid')
      end

    end

  end

end
