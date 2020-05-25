require 'rails_helper'

RSpec.describe Payments::Response do

  describe '.call' do
    before { allow(Payments::Response).to receive(:call).and_call_original }


    context 'AUTHORIZATION RESPONSE' do

      it 'sets payment status to authorized' do
        order = create(:order, :with_payment)
        order.payment.update(merchant_reference: AUTHORIZATION_RESPONSE[:merchant_reference])
        params = ActionController::Parameters.new(AUTHORIZATION_RESPONSE.merge({order: order.id}))
        result = Payments::Response.call(params: params)
        expect(result).to be_a_success
        expect(order.reload.paid).to be_truthy
        expect(order.reload.payment.status).to eq('authorized')
      end

      it 'should call OrderCanceletionWorker' do
        expect(OrderCanceletionWorker).to receive(:perform_in).with(1.hour, kind_of(Integer), :not_approved)
        order = create(:order, :with_payment)
        order.payment.update(merchant_reference: AUTHORIZATION_RESPONSE[:merchant_reference])
        params = ActionController::Parameters.new(AUTHORIZATION_RESPONSE.merge({order: order.id}))
        Payments::Response.call(params: params)
      end


      it 'sets payment status to failed if status not 02000' do
        order = create(:order, :with_payment)
        order.payment.update(merchant_reference: CUSTOM_PAYFORT_AUTHORIZATION_RESPONSE_FAIL[:merchant_reference])
        params = ActionController::Parameters.new(CUSTOM_PAYFORT_AUTHORIZATION_RESPONSE_FAIL.merge({order: order.id}))
        result = Payments::Response.call(params: params)
        expect(result).to be_a_success
        expect(order.reload.paid).to be_falsey
        expect(order.reload.payment.status).to eq('failed')
      end


      it 'should send push about new order to the seller' do
        expect(Push::Generator).to receive(:call).with({
                                                           user: kind_of(User),
                                                           notification: :order_created,
                                                           order: kind_of(Order)
                                                       })

        order = create(:order, :with_payment_3ds_required)
        order.payment.update(merchant_reference: AUTHORIZATION_RESPONSE[:merchant_reference])
        params = ActionController::Parameters.new(AUTHORIZATION_RESPONSE.merge({order: order.id}))
        Payments::Response.call(params: params)
      end


      it 'returns error if order not found' do
        create(:order, :with_payment)
        params = ActionController::Parameters.new(CALLBACK_PAYFORT_AUTHORIZATION__SUCCESS)
        result = Payments::Response.call(params: params)
        expect(result).to be_a_failure
        expect(result.errors).to eq 'Invalid merchant_reference'
      end


      it 'returns error if signature wrong' do
        create(:order, :with_payment)
        params = ActionController::Parameters.new(CALLBACK_PAYFORT_AUTHORIZATION__SUCCESS.merge({signature: '123'}))
        result = Payments::Response.call(params: params)
        expect(result).to be_a_failure
        expect(result.errors).to eq 'Invalid signature'
      end


      it 'returns response if order payment can not be authorized' do
        order = create(:order, :with_payment_authorized)
        order.payment.update(merchant_reference: CALLBACK_PAYFORT_AUTHORIZATION__SUCCESS[:merchant_reference])
        params = ActionController::Parameters.new(CALLBACK_PAYFORT_AUTHORIZATION__SUCCESS)
        result = Payments::Response.call(params: params)
        expect(result).to be_a_success
        expect(result.params).to eq(CALLBACK_PAYFORT_AUTHORIZATION__SUCCESS)

      end

    end


    context 'TOKENIZATION RESPONSE' do
      it 'returns response' do
        params = ActionController::Parameters.new(TOKENIZATION_RESPONSE_2)
        result = Payments::Response.call(params: params)
        expect(result).to be_a_success
        expect(result.params).to eq(TOKENIZATION_RESPONSE_2)

      end
    end

  end

end
