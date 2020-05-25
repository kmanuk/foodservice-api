require 'rails_helper'

RSpec.describe Orders::Calculator do
  describe '.call' do
    let(:user)  { create(:user, role: :seller, address: create(:address))}
    let(:item1) { create(:item, price: 10, user: user) }
    let(:item2) { create(:item, price: 20, user: user) }
    let(:item3) { create(:item, :free_item, user: user) }

    def build_params delivery_type, free = false
      line_items = if free
        [{ item_id: item3.id, quantity: 2 }]
      else
        [
          { item_id: item1.id, quantity: 1 },
          { item_id: item2.id, quantity: 6 }
        ]
      end

      ActionController::Parameters.new(
        order: {
          delivery_type: delivery_type,
          line_items: line_items,
          address_attributes: {
            location: 'Kiev, Khreshchatyk, Ukraine',
            latitude: "50.42039314710917",
            longitude: "30.51263809204102"
          }
        }
      )
    end

    # for expect_any_instance_of(GoogleMapsService::Client)
    def direction_params
      [{ overview_polyline: { points: '' }, legs: [{ distance: { value: 1 }, duration: { value: 1 } }] }]
    end

    context 'for self_delivery' do
      it 'should calculate price without delivery' do
        result = Orders::Calculator.call(params: build_params('self_delivery'))
        expect(result).to be_a_success
        expect(result.price).not_to be_nil
        expect(result.price.delivery_price).to eq 0
        expect(result.price.distance).to eq 0
        expect(result.price.duration).to eq 0
        expect(result.price.polyline).to eq ''
        expect(result.price.price).to eq (item1.price + item2.price * 6)
        expect(result.price.total_price).to eq (item1.total_price + item2.total_price * 6)
        expect(result.price.fee_price).to eq (item1.total_price + item2.total_price * 6) - (item1.price + item2.price * 6)
        expect(result.price.global_price).to eq (item1.total_price + item2.total_price * 6 + 2).ceil
      end

      it 'should not call google maps service' do
        expect_any_instance_of(GoogleMapsService::Client).not_to receive(:directions)
        Orders::Calculator.call(params: build_params('self_delivery'))
      end

      context 'for free items' do
        it 'should not add service fee' do
          result = Orders::Calculator.call(params: build_params('self_delivery', true))
          expect(result).to be_a_success
          expect(result.price).not_to be_nil
          expect(result.price.service_fee).to eq 0
          expect(result.price.global_price).to eq 0
        end
      end

      context 'for paid items' do
        it 'should add service fee' do
          result = Orders::Calculator.call(params: build_params('self_delivery'))
          expect(result).to be_a_success
          expect(result.price).not_to be_nil
          expect(result.price.service_fee).to eq Order::SERVICE_FEE
        end
      end
    end

    context 'for regular_driver' do
      it 'should calculate price with delivery' do
        result = Orders::Calculator.call(params: build_params('regular_driver'))
        expect(result).to be_a_success
        expect(result.price).not_to be_nil
        expect(result.price.distance).to eq 2404
        expect(result.price.duration).to eq 103
        expect(result.price.polyline).not_to eq ''
        expect(result.price.delivery_price).to eq 4.8
        expect(result.price.price).to eq(item1.price + item2.price * 6)
        expect(result.price.total_price).to eq(item1.total_price + item2.total_price * 6)
        expect(result.price.fee_price).to eq (item1.total_price + item2.total_price * 6) - (item1.price + item2.price * 6)
        expect(result.price.global_price).to eq (item1.total_price + item2.total_price * 6 + 4.8 + 2).ceil
      end

      it 'should call google maps service' do
        expect_any_instance_of(GoogleMapsService::Client).to receive(:directions).with(
          user.address.coordinates,
          ["50.42039314710917", "30.51263809204102"],
          alternatives: false,
          units: 'metric'
        ).once.and_return(direction_params)
        Orders::Calculator.call(params: build_params('regular_driver'))
      end

      it 'should add service fee' do
        result = Orders::Calculator.call(params: build_params('regular_driver'))
        expect(result).to be_a_success
        expect(result.price).not_to be_nil
        expect(result.price.service_fee).to eq Order::SERVICE_FEE
      end
    end

    context 'for certified_driver' do
      it 'should calculate price with delivery' do
        result = Orders::Calculator.call(params: build_params('certified_driver'))
        expect(result).to be_a_success
        expect(result.price).not_to be_nil
        expect(result.price.distance).to eq 2404
        expect(result.price.duration).to eq 103
        expect(result.price.polyline).not_to eq ''
        expect(result.price.delivery_price).to eq 6.8
        expect(result.price.price).to eq(item1.price + item2.price * 6)
        expect(result.price.total_price).to eq(item1.total_price + item2.total_price * 6)
        expect(result.price.fee_price).to eq (item1.total_price + item2.total_price * 6) - (item1.price + item2.price * 6)
        expect(result.price.global_price).to eq (item1.total_price + item2.total_price * 6 + 6.8 + 2).ceil
      end

      it 'should call google maps service' do
        expect_any_instance_of(GoogleMapsService::Client).to receive(:directions).with(
          user.address.coordinates,
          ["50.42039314710917", "30.51263809204102"],
          alternatives: false,
          units: 'metric'
        ).once.and_return(direction_params)
        Orders::Calculator.call(params: build_params('certified_driver'))
      end

      it 'should add service fee' do
        result = Orders::Calculator.call(params: build_params('certified_driver'))
        expect(result).to be_a_success
        expect(result.price).not_to be_nil
        expect(result.price.service_fee).to eq Order::SERVICE_FEE
      end
    end

    context 'if can not find address' do
      it 'should fail' do
        params = build_params('certified_driver')
        params[:order][:address_attributes] = nil
        result = Orders::Calculator.call(params: params)
        expect(result).to be_a_failure
        expect(result.errors).to eq 'Address can not be blank'
      end
    end

    context 'if can not build route' do
      it 'shoild fail' do
        stub_request(:get, /maps.googleapis.com\/maps\/api\/directions/).to_return(
          body: { status: 'SOME_ERROR', error_message: 'API error' }.to_json
        )

        result = Orders::Calculator.call(params: build_params('certified_driver'))
        expect(result).to be_a_failure
        expect(result.errors).to eq 'Can not build route'
      end

      it 'should render error' do
        allow_any_instance_of(GoogleMapsService::Client).to receive(:directions).and_return([])
        result = Orders::Calculator.call(params: build_params('certified_driver'))
        expect(result).to be_a_failure
        expect(result.errors).to eq 'Can not build route'
      end
    end
  end
end
