require 'rails_helper'

RSpec.describe Payments::CancelAuthorization do
  describe '.call' do
    before { allow(Payments::CancelAuthorization).to receive(:call).and_call_original }

    before(:each) do
      stub_request(:post, 'https://sbpaymentservices.payfort.com/FortAPI/paymentApi').to_return(
          body: CANCEL_SUCCESS_RESPONSE.to_json
      )
    end

    context 'Cancel Authorization request' do
      let(:order) { create(:fast_created_order, :with_payment) }
      it 'change status of the payment to canceled' do
        result = Payments::CancelAuthorization.call(order: order)
        expect(result).to be_a_success
        expect(order.reload.payment.status).to eq('canceled')
      end

    end

  end

end
