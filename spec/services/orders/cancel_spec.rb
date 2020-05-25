require 'rails_helper'

RSpec.describe Orders::Cancel do
  describe '.call' do
    before { allow(Orders::Cancel).to receive(:call).and_call_original }

    before(:each) do
      stub_request(:post, 'https://sbpaymentservices.payfort.com/FortAPI/paymentApi').to_return(
          body: CANCEL_SUCCESS_RESPONSE.to_json
      )
    end

    let(:live_item1) { create(:item, name: 'Coke', price: 1.0, amount: 0) }
    let(:live_item2) { create(:item, name: 'Sandwich', price: 3.0, amount: 0) }
    let(:line_items_live) { [create(:line_item, quantity: 2, item_id: live_item1.id),
                             create(:line_item, quantity: 3, item_id: live_item2.id)] }

    context 'when seller made request' do
      let(:seller) { create(:seller) }
      let(:order) { create(:order, :with_payment, seller: seller, line_items: line_items_live) }

      it 'does not increase amount of items if status pending' do
        order.update(status: 'pending')
        result = Orders::Cancel.call(user: seller, order: order)
        expect(result).to be_a_success
        expect(live_item1.reload.amount).to eq(0)
        expect(live_item2.reload.amount).to eq(0)
      end

      it 'creates cancellation record for the order' do

        expect(CancellationService).to receive(:call).with({
                                                          order: order,
                                                          who: 'seller'
                                                      }).once

        Orders::Cancel.call(user: seller, order: order)
      end

      it 'does not increase amount of items if status looking_for_driver' do
        order.update(status: 'looking_for_driver')
        result = Orders::Cancel.call(user: seller, order: order)
        expect(result).to be_a_success
        expect(live_item1.reload.amount).to eq(0)
        expect(live_item2.reload.amount).to eq(0)
      end

      it 'increases amount of items' do
        order.update(status: 'ready')
        result = Orders::Cancel.call(user: seller, order: order)
        expect(result).to be_a_success
        expect(live_item1.reload.amount).to eq(2)
        expect(live_item2.reload.amount).to eq(3)
      end


      it 'sets status to canceled' do
        result = Orders::Cancel.call(user: seller, order: order)
        expect(result).to be_a_success
        expect(result.order.status).to eq('canceled')
      end

      it 'returns error if status picking_up' do
        order.update(status: 'picking_up')
        result = Orders::Cancel.call(user: seller, order: order)
        expect(result).not_to be_a_success
        expect(result.errors).to eq('You cannot cancel this order right now')
      end

      it 'returns error if status on_the_way' do
        order.update(status: 'on_the_way')
        result = Orders::Cancel.call(user: seller, order: order)
        expect(result).not_to be_a_success
        expect(result.errors).to eq('You cannot cancel this order right now')
      end

      it 'returns error if status delivered' do
        order.update(status: 'delivered')
        result = Orders::Cancel.call(user: seller, order: order)
        expect(result).not_to be_a_success
        expect(result.errors).to eq('You cannot cancel this order right now')
      end

      it 'returns error if this user does not belongs to this order' do
        order = create(:order)
        result = Orders::Cancel.call(user: seller, order: order)
        expect(result).not_to be_a_success
        expect(result.errors).to eq('This user does not belongs to this order')
      end

      it 'should send push notification' do
        expect(Push::Generator).to receive(:call).with({
                                                           users: [order.buyer, order.driver],
                                                           notification: :canceled_by_seller,
                                                           order: order
                                                       }).once

        Orders::Cancel.call(user: order.seller, order: order)
      end
    end

    context 'when driver made request' do
      let(:driver) { create(:driver) }
      let(:order) { create(:fast_created_order, :with_payment, driver: driver, status: 'ready', line_items: line_items_live) }

      it 'increases amount of items' do
        result = Orders::Cancel.call(user: driver, order: order)
        expect(result).to be_a_success
        expect(live_item1.reload.amount).to eq(2)
        expect(live_item2.reload.amount).to eq(3)
      end

      it 'creates cancellation record for the order' do
        expect(CancellationService).to receive(:call).with({
                                                               order: order,
                                                               who: 'driver'
                                                           }).once

        Orders::Cancel.call(user: driver, order: order)

      end

      it 'sets status to looking_for_driver' do
        result = Orders::Cancel.call(user: driver, order: order)
        expect(result).to be_a_success
        expect(result.order.status).to eq('looking_for_driver')
      end

      it 'starts to find driver' do
        expect_any_instance_of(Order).to receive(:find_driver!).with(with_canceletion: false).once
        Orders::Cancel.call(user: driver, order: order)
      end

      it 'removes driver from the order' do
        result = Orders::Cancel.call(user: driver, order: order)
        expect(result).to be_a_success
        expect(result.order.driver).to eq(nil)
      end

      it 'returns error if this user does not belongs to this order' do
        order = create(:order)
        result = Orders::Cancel.call(user: driver, order: order)
        expect(result).not_to be_a_success
        expect(result.errors).to eq('This user does not belongs to this order')
      end


      it 'should send push notification' do
        expect(Push::Generator).to receive(:call).with({
                                                           users: [order.seller, order.buyer],
                                                           notification: :canceled_by_driver,
                                                           order: order
                                                       }).once

        Orders::Cancel.call(user: order.driver, order: order)
      end

      it 'returns error if status picking_up' do
        order.update(status: 'picking_up')
        result = Orders::Cancel.call(user: driver, order: order)
        expect(result).not_to be_a_success
        expect(result.errors).to eq('You cannot cancel this order right now')
      end

      it 'returns error if status on_the_way' do
        order.update(status: 'on_the_way')
        result = Orders::Cancel.call(user: driver, order: order)
        expect(result).not_to be_a_success
        expect(result.errors).to eq('You cannot cancel this order right now')
      end

      it 'returns error if status delivered' do
        order.update(status: 'delivered')
        result = Orders::Cancel.call(user: driver, order: order)
        expect(result).not_to be_a_success
        expect(result.errors).to eq('You cannot cancel this order right now')
      end

    end

    it 'returns error if request was made by buyer' do
      order = create(:order)
      result = Orders::Cancel.call(user: order.buyer, order: order)
      expect(result).not_to be_a_success
      expect(result.errors).to eq('Only Driver or Seller can cancel the order')
    end
  end
end
