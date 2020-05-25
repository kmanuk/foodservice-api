require 'rails_helper'

RSpec.describe Orders::Create do
  describe '.call' do

    before { allow(Orders::Create).to receive(:call).and_call_original }


    let(:buyer) { create(:buyer) }

    let(:live_item1) { create(:item, name: 'Coke', price: 1.0, amount: 4) }
    let(:live_item2) { create(:item, name: 'Sandwich', price: 3.0, amount: 3) }

    let(:preorder_item1) { create(:item, :preorder_item, name: 'Steak', price: 25.0, time_to_cook: 25.5) }
    let(:preorder_item2) { create(:item, :preorder_item, name: 'Salad', price: 5.0, time_to_cook: 10.5) }

    let(:line_items_live_attributes) { [{item_id: live_item1.id, quantity: 1},
                                        {item_id: live_item2.id, quantity: 2}] }

    let(:line_items_preorder_attributes) { [{item_id: preorder_item1.id, quantity: 1},
                                            {item_id: preorder_item2.id, quantity: 2}] }

    let(:payment_data) { {card_number: TOKENIZATION_RESPONSE[:card_number],
                          card_bin: TOKENIZATION_RESPONSE[:card_bin],
                          expiry_date: TOKENIZATION_RESPONSE[:expiry_date],
                          merchant_reference: TOKENIZATION_RESPONSE[:merchant_reference],
                          token_name: TOKENIZATION_RESPONSE[:token_name],
                          card_holder_name: TOKENIZATION_RESPONSE[:card_holder_name]} }

    def build_params(params = {})
      ActionController::Parameters.new(
          order: {
              line_items: params[:line_items],
              address_attributes: params[:address],
              delivery_type: params[:delivery_type],
              type: params[:type],
              payment_attributes: params[:payment_data],
              payment_type: params[:payment_type]
          }
      )
    end

    context 'if can not calculate price' do
      it 'should return error' do
        allow(Orders::Calculator).to receive(:call).and_return(InteractorStub.new(failed: true, errors: 'Some error'))


        result = Orders::Create.call(buyer: buyer,
                                     params: build_params({line_items: line_items_live_attributes,
                                                           address: attributes_for(:address),
                                                           delivery_type: 'self_delivery',
                                                           type: 'live'}))
        expect(result).to be_a_failure
        expect(result.errors).to eq 'Some error'
      end
    end

    context 'if can not save order' do
      it 'should return error' do
        allow_any_instance_of(Order).to receive(:save).and_return(false)

        result = Orders::Create.call(buyer: buyer,
                                     params: build_params({line_items: line_items_live_attributes,
                                                           address: attributes_for(:address),
                                                           delivery_type: 'self_delivery',
                                                           type: 'live'}))
        expect(result).to be_a_failure
      end
    end

    context 'if can not save payment' do
      it 'should return error' do
        allow_any_instance_of(Payment).to receive(:save).and_return(false)

        result = Orders::Create.call(buyer: buyer,
                                     params: build_params({line_items: line_items_live_attributes,
                                                           address: attributes_for(:address),
                                                           delivery_type: 'self_delivery',
                                                           type: 'live',
                                                           payment_data: payment_data}))
        expect(result).to be_a_failure
      end
    end

    context 'if seller has no this amount of item' do
      it 'should return error' do
        result = Orders::Create.call(buyer: buyer,
                                     params: build_params({line_items: [{item_id: live_item1.id, quantity: 6},
                                                                        {item_id: live_item2.id, quantity: 2}],
                                                           address: attributes_for(:address),
                                                           delivery_type: 'self_delivery',
                                                           type: 'live'}))
        expect(result).to be_a_failure
        expect(result.errors).to eq 'Seller has no this amount of items'
      end
    end

    context 'if item was not found' do
      it 'should return error' do
        result = Orders::Create.call(buyer: buyer,
                                     params: build_params({line_items: [{item_id: 99, quantity: 6},
                                                                        {item_id: live_item2.id, quantity: 2}],
                                                           address: attributes_for(:address),
                                                           delivery_type: 'self_delivery',
                                                           type: 'live'}))
        expect(result).to be_a_failure
        expect(result.errors).to eq 'Item not found'
      end
    end

    context 'Create' do

      context 'Free Order' do

        it 'should create order without payment' do

          result = Orders::Create.call(buyer: buyer,
                                       params: build_params({line_items: line_items_live_attributes,
                                                             address: attributes_for(:address),
                                                             delivery_type: 'self_delivery',
                                                             type: 'free'}))
          expect(result).to be_a_success
          expect(result.order.price).to eq(7.0)
          expect(result.order.total_price).to eq(7.7)
          expect(result.order.fee_price).to eq(0.7)
          expect(result.order.delivery_price).to eq(0)
          expect(result.order.service_fee).to eq(2)
          expect(result.order.global_price).to eq(10.0)
          expect(result.order.status).to eq('pending')
          expect(result.order.delivery_type).to eq('self_delivery')
          expect(result.order.type).to eq('free')
          expect(result.order.line_items.first.item_id).to eq(live_item1.id)
          expect(result.order.line_items.first.name).to eq('Coke')
          expect(result.order.line_items.first.total_price).to eq(1.1)
          expect(result.order.line_items.last.item_id).to eq(live_item2.id)
          expect(result.order.line_items.last.name).to eq('Sandwich')
          expect(result.order.line_items.last.total_price).to eq(6.6)
          expect(result.order.driver).to be_nil
          expect(result.order.cooking_time).to eq(0)

          expect(result.payment_result).to be_nil
          order = Order.find_by(id: result.order.id)
          expect(order.paid).to be_truthy
          expect(order.payment).to be_nil
        end

        it 'should create order with payment' do

          stub_request(:post, 'https://sbpaymentservices.payfort.com/FortAPI/paymentApi').to_return(
              body: D_SECURE_REQUESTED.to_json
          )

          result = Orders::Create.call(buyer: buyer,
                                       params: build_params({line_items: line_items_live_attributes,
                                                             address: attributes_for(:address),
                                                             delivery_type: 'certified_driver',
                                                             type: 'free',
                                                             payment_data: payment_data,
                                                            }),
                                       ip: '8.8.8.8')
          expect(result).to be_a_success
          expect(result.order.price).to eq(7.0)
          expect(result.order.total_price).to eq(7.7)
          expect(result.order.fee_price).to eq(0.7)
          expect(result.order.delivery_price).to eq(6.8)
          expect(result.order.service_fee).to eq(2)
          expect(result.order.global_price).to eq(17.0)
          expect(result.order.status).to eq('pending')
          expect(result.order.delivery_type).to eq('certified_driver')
          expect(result.order.type).to eq('free')
          expect(result.order.line_items.first.item_id).to eq(live_item1.id)
          expect(result.order.line_items.first.name).to eq('Coke')
          expect(result.order.line_items.first.total_price).to eq(1.1)
          expect(result.order.line_items.last.item_id).to eq(live_item2.id)
          expect(result.order.line_items.last.name).to eq('Sandwich')
          expect(result.order.line_items.last.total_price).to eq(6.6)
          expect(result.order.driver).to be_nil
          expect(result.order.cooking_time).to eq(0)

          expect(result.payment_result['3ds_url']).to eq(D_SECURE_REQUESTED.stringify_keys['3ds_url'])
          order = Order.find_by(id: result.order.id)
          expect(order.payment.token).to eq(TOKENIZATION_RESPONSE[:token_name])
          expect(order.payment.card_number).to eq(TOKENIZATION_RESPONSE[:card_number])
          expect(order.payment.expiry_date).to eq(D_SECURE_REQUESTED[:expiry_date])
          expect(order.payment.card_bin).to eq(TOKENIZATION_RESPONSE[:card_bin])
          expect(order.payment.card_holder_name).to eq(D_SECURE_REQUESTED[:card_holder_name])
          expect(order.payment.ip_address).to eq('8.8.8.8')
          expect(order.payment.status).to eq('3ds_required')
          expect(order.payment.merchant_reference).to eq(TOKENIZATION_RESPONSE[:merchant_reference])
        end

      end

      context 'Live Order' do

        before do
          stub_request(:post, 'https://sbpaymentservices.payfort.com/FortAPI/paymentApi').to_return(
              body: D_SECURE_REQUESTED.to_json
          )

        end

        it 'should create order with payment' do

          result = Orders::Create.call(buyer: buyer,
                                       params: build_params({line_items: line_items_live_attributes,
                                                             address: attributes_for(:address),
                                                             delivery_type: 'self_delivery',
                                                             type: 'live',
                                                             payment_data: payment_data}),
                                       ip: '8.8.8.8')
          expect(result).to be_a_success
          expect(result.order.price).to eq(7.0)
          expect(result.order.total_price).to eq(7.7)
          expect(result.order.fee_price).to eq(0.7)
          expect(result.order.delivery_price).to eq(0)
          expect(result.order.service_fee).to eq(2)
          expect(result.order.global_price).to eq(10.0)
          expect(result.order.status).to eq('pending')
          expect(result.order.delivery_type).to eq('self_delivery')
          expect(result.order.type).to eq('live')
          expect(result.order.line_items.first.item_id).to eq(live_item1.id)
          expect(result.order.line_items.first.name).to eq('Coke')
          expect(result.order.line_items.first.total_price).to eq(1.1)
          expect(result.order.line_items.last.item_id).to eq(live_item2.id)
          expect(result.order.line_items.last.name).to eq('Sandwich')
          expect(result.order.line_items.last.total_price).to eq(6.6)
          expect(result.order.driver).to be_nil
          expect(result.order.cooking_time).to eq(0)
        end

        it 'should not call OrderCanceletionWorker' do
          expect(OrderCanceletionWorker).not_to receive(:perform_in).with(1.hour, kind_of(Integer), :not_approved)


          result = Orders::Create.call(buyer: buyer,
                                       params: build_params({line_items: line_items_live_attributes,
                                                             address: attributes_for(:address),
                                                             delivery_type: 'self_delivery',
                                                             type: 'live',
                                                             payment_data: payment_data}),
                                       ip: '8.8.8.8')
        end

      end

      context 'Preorder Order' do
        before(:each) do
          stub_request(:post, 'https://sbpaymentservices.payfort.com/FortAPI/paymentApi').to_return(
              body: D_SECURE_REQUESTED.to_json
          )
        end

        it 'should create order with preorder items' do
          params = build_params({line_items: line_items_preorder_attributes,
                                 address: attributes_for(:address),
                                 delivery_type: 'self_delivery',
                                 type: 'preorder',
                                 payment_data: payment_data})

          result = Orders::Create.call(buyer: buyer, params: params, ip: '8.8.8.8')

          expect(result).to be_a_success
          expect(result.order.price).to eq(35.0)
          expect(result.order.total_price).to eq(38.5)
          expect(result.order.fee_price).to eq(3.5)
          expect(result.order.delivery_price).to eq(0)
          expect(result.order.service_fee).to eq(2)
          expect(result.order.global_price).to eq(41.0)
          expect(result.order.status).to eq('pending')
          expect(result.order.delivery_type).to eq('self_delivery')
          expect(result.order.type).to eq('preorder')
          expect(result.order.line_items.first.item_id).to eq(preorder_item1.id)
          expect(result.order.line_items.first.name).to eq('Steak')
          expect(result.order.line_items.first.total_price).to eq(27.5)
          expect(result.order.line_items.last.item_id).to eq(preorder_item2.id)
          expect(result.order.line_items.last.name).to eq('Salad')
          expect(result.order.line_items.last.total_price).to eq(11.0)
          expect(result.order.driver).to be_nil
          expect(result.order.cooking_time).to eq(47) # ( 25.5 + 10.5 * 2 ).round = 47
        end

        it 'should not call OrderCanceletionWorker' do
          expect(OrderCanceletionWorker).not_to receive(:perform_in).with(1.hour, kind_of(Integer), :not_approved)

          params = build_params({line_items: line_items_preorder_attributes,
                                 address: attributes_for(:address),
                                 delivery_type: 'self_delivery',
                                 type: 'preorder',
                                 payment_data: payment_data})

          result = Orders::Create.call(buyer: buyer, params: params, ip: '8.8.8.8')

        end
      end

      context 'Order with payment' do

        it 'without 3d secure request' do
          stub_request(:post, 'https://sbpaymentservices.payfort.com/FortAPI/paymentApi').to_return(
              body: AUTHORIZATION_RESPONSE.to_json
          )

          result = Orders::Create.call(buyer: buyer,
                                       params: build_params({line_items: line_items_live_attributes,
                                                             address: attributes_for(:address),
                                                             delivery_type: 'self_delivery',
                                                             type: 'live',
                                                             payment_data: payment_data}),
                                       ip: '8.8.8.8')
          expect(result).to be_a_success

          order = Order.find_by(id: result.order.id)
          expect(order.payment.token).to eq(TOKENIZATION_RESPONSE[:token_name])
          expect(order.payment.card_number).to eq(TOKENIZATION_RESPONSE[:card_number])
          expect(order.payment.card_bin).to eq(TOKENIZATION_RESPONSE[:card_bin])
          expect(order.payment.status).to eq('authorized')
          expect(order.payment.ip_address).to eq('8.8.8.8')
          expect(order.payment.merchant_reference).to eq(TOKENIZATION_RESPONSE[:merchant_reference])
        end

        it 'with 3d secure request' do

          stub_request(:post, 'https://sbpaymentservices.payfort.com/FortAPI/paymentApi').to_return(
              body: D_SECURE_REQUESTED.to_json
          )

          result = Orders::Create.call(buyer: buyer,
                                       params: build_params({line_items: line_items_live_attributes,
                                                             address: attributes_for(:address),
                                                             delivery_type: 'self_delivery',
                                                             type: 'live',
                                                             payment_data: payment_data}),
                                       ip: '8.8.8.8')
          expect(result).to be_a_success

          expect(result.payment_result['3ds_url']).to eq(D_SECURE_REQUESTED.stringify_keys['3ds_url'])
          order = Order.find_by(id: result.order.id)
          expect(order.payment.token).to eq(TOKENIZATION_RESPONSE[:token_name])
          expect(order.payment.card_number).to eq(TOKENIZATION_RESPONSE[:card_number])
          expect(order.payment.expiry_date).to eq(D_SECURE_REQUESTED[:expiry_date])
          expect(order.payment.card_bin).to eq(TOKENIZATION_RESPONSE[:card_bin])
          expect(order.payment.card_holder_name).to eq(D_SECURE_REQUESTED[:card_holder_name])
          expect(order.payment.status).to eq('3ds_required')
          expect(order.payment.ip_address).to eq('8.8.8.8')
          expect(order.payment.merchant_reference).to eq(TOKENIZATION_RESPONSE[:merchant_reference])
        end

        it 'sets payment to failed' do
          stub_request(:post, 'https://sbpaymentservices.payfort.com/FortAPI/paymentApi').to_return(
              body: CUSTOM_PAYFORT_AUTHORIZATION_RESPONSE_FAIL.to_json
          )

          result = Orders::Create.call(buyer: buyer,
                                       params: build_params({line_items: line_items_live_attributes,
                                                             address: attributes_for(:address),
                                                             delivery_type: 'self_delivery',
                                                             type: 'live',
                                                             payment_data: payment_data}),
                                       ip: '8.8.8.8')
          expect(result).to be_a_success
          order = Order.find_by(id: result.order.id)
          expect(order.payment.status).to eq('failed')
        end

      end
    end

    it 'should call OrderCanceletionWorker' do
      expect(OrderCanceletionWorker).to receive(:perform_in).with(1.hour, kind_of(Integer), :not_approved)

      Orders::Create.call(buyer: buyer,
                          params: build_params({line_items: line_items_live_attributes,
                                                address: attributes_for(:address),
                                                delivery_type: 'self_delivery',
                                                type: 'free'}))
    end

    context 'Push to Seller about new Order' do

      it 'for order authroized payment without 3d-secure' do
        stub_request(:post, 'https://sbpaymentservices.payfort.com/FortAPI/paymentApi').to_return(
            body: AUTHORIZATION_RESPONSE.to_json
        )


        expect(Push::Generator).to receive(:call).with({
                                                           user: kind_of(User),
                                                           notification: :order_created,
                                                           order: kind_of(Order)
                                                       }).once

        Orders::Create.call(buyer: buyer,
                            params: build_params({line_items: line_items_live_attributes,
                                                  address: attributes_for(:address),
                                                  delivery_type: 'self_delivery',
                                                  type: 'preorder',
                                                  payment_type: 'cash'}))
      end


      it 'for order by cash' do
        expect(Push::Generator).to receive(:call).with({
                                                           user: kind_of(User),
                                                           notification: :order_created,
                                                           order: kind_of(Order)
                                                       }).once

        Orders::Create.call(buyer: buyer,
                            params: build_params({line_items: line_items_live_attributes,
                                                  address: attributes_for(:address),
                                                  delivery_type: 'self_delivery',
                                                  type: 'preorder',
                                                  payment_type: 'cash'}))
      end

      it 'for order all free' do
        expect(Push::Generator).to receive(:call).with({
                                                           user: kind_of(User),
                                                           notification: :order_created,
                                                           order: kind_of(Order)
                                                       }).once

        Orders::Create.call(buyer: buyer,
                            params: build_params({line_items: line_items_live_attributes,
                                                  address: attributes_for(:address),
                                                  delivery_type: 'self_delivery',
                                                  type: 'free'}))
      end

      it 'should not send push to seller for unpaid order' do

        stub_request(:post, 'https://sbpaymentservices.payfort.com/FortAPI/paymentApi').to_return(
            body: D_SECURE_REQUESTED.to_json
        )


        expect(Push::Generator).not_to receive(:call).with({
                                                               user: kind_of(User),
                                                               notification: :order_created,
                                                               order: kind_of(Order)
                                                           })

        Orders::Create.call(buyer: buyer,
                            params: build_params({line_items: line_items_live_attributes,
                                                  address: attributes_for(:address),
                                                  delivery_type: 'self_delivery',
                                                  type: 'live',
                                                  payment_data: payment_data}))
      end


    end


  end
end
