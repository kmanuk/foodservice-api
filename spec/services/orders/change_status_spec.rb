require 'rails_helper'

RSpec.describe Orders::ChangeStatus do
  describe '.call' do
    before { allow(Orders::ChangeStatus).to receive(:call).and_call_original }

    before(:each) do
      stub_request(:post, 'https://sbpaymentservices.payfort.com/FortAPI/paymentApi').to_return(
          body: CAPTURE_SUCCESS_RESPONSE.to_json
      )
    end

    it 'should send push notification' do
      order = create(:order, :ready, :self_delivery)

      expect(Push::Generator).to receive(:call).with({
                                                         users: order.members(exclude: order.buyer.id),
                                                         notification: :change_status,
                                                         order: order
                                                     }).once

      result = Orders::ChangeStatus.call(user: order.buyer, order: order)
      expect(result).to be_a_success
    end


    context 'when seller made request' do
      let(:seller) { create(:seller) }

      context 'current status cooking' do
        let(:order) { create(:order, :preorder, :cooking, seller: seller) }

        it_behaves_like 'seller change status to', 'ready'
      end

      context 'current status pending' do
        context 'driver delivery' do
          context 'for live/free' do
            let(:order) { create(:order, seller: seller) }

            it_behaves_like 'seller change status to', 'looking_for_driver'

            it 'starts to find driver' do
              expect_any_instance_of(Order).to receive(:find_driver!).once
              Orders::ChangeStatus.call(user: seller, order: order)
            end
          end

          context 'for the preorder' do
            let(:order) { create(:order, :preorder, seller: seller) }

            it_behaves_like 'seller change status to', 'looking_for_driver'

            it 'starts to find driver' do
              expect_any_instance_of(Order).to receive(:find_driver!).once
              Orders::ChangeStatus.call(user: seller, order: order)
            end

            it 'sets cooking time' do
              result = Orders::ChangeStatus.call(user: seller, order: order, cooking_time: '120')
              expect(result).to be_a_success
              expect(result.order.cooking_time).to eq(120)
            end

            it 'sets cooking notification job' do
              expect(CookingNotificationWorker).to receive(:perform_in).with(120.minutes, order.id).once
              Orders::ChangeStatus.call(user: seller, order: order, cooking_time: '120')
            end
          end
        end

        context 'self delivery' do

          context 'for live/free' do

            let(:live_item1) { create(:item, name: 'Coke', price: 1.0, amount: 4) }
            let(:live_item2) { create(:item, name: 'Sandwich', price: 3.0, amount: 3) }
            let(:line_items_live) { [create(:line_item, quantity: 2, item_id: live_item1.id),
                                     create(:line_item, quantity: 3, item_id: live_item2.id)] }

            let(:order) { create(:order, :with_payment, :self_delivery, seller: seller, line_items: line_items_live) }

            it_behaves_like 'seller change status to', 'ready'

            it 'should reduce amount of items' do
              result = Orders::ChangeStatus.call(user: seller, order: order)
              expect(result).to be_a_success
              expect(live_item1.reload.amount).to eq(2)
              expect(live_item2.reload.amount).to eq(0)
            end
          end

          context 'for the preorder ' do

            let(:preorder_item1) { create(:item, :preorder_item, name: 'Steak', price: 25.0, amount: 4, time_to_cook: 25.5) }
            let(:preorder_item2) { create(:item, :preorder_item, name: 'Salad', price: 5.0, amount: 3, time_to_cook: 10.5) }

            let(:line_items_preorder) { [create(:line_item, quantity: 2, item_id: preorder_item1.id),
                                         create(:line_item, quantity: 3, item_id: preorder_item2.id)] }

            let(:order) { create(:order,
                                 :with_payment,
                                 :preorder,
                                 :self_delivery, seller: seller, cooking_time: 120, line_items: line_items_preorder) }

            it_behaves_like 'seller change status to', 'cooking'

            it 'sets estimation ready time' do
              result = Orders::ChangeStatus.call(user: seller, order: order)
              expect(result).to be_a_success
              expect(result.order.estimation_ready.strftime('%Y-%m-%dT%H:%M')).to eq((Time.now + 120.minutes).utc.strftime('%Y-%m-%dT%H:%M'))
            end

            it 'should reduce amount of items' do
              result = Orders::ChangeStatus.call(user: seller, order: order)
              expect(result).to be_a_success
              expect(preorder_item1.reload.amount).to eq(2)
              expect(preorder_item2.reload.amount).to eq(0)
            end

          end

          context 'start the order' do
            let(:order) { create(:order, :with_payment_authorized, :self_delivery, seller: seller) }

            it 'should call payment method' do
              expect_any_instance_of(Payments::Capture).to receive(:call)
              Orders::ChangeStatus.call(user: seller, order: order)
            end

            it 'checks amount availability' do
              expect_any_instance_of(Orders::ChangeStatus).to receive(:amount_available?)
              Orders::ChangeStatus.call(user: seller, order: order)
            end

          end

        end
      end

      it 'returns error if request was made on wrong step' do
        order = create(:order, :on_the_way, seller: seller)
        result = Orders::ChangeStatus.call(user: seller, order: order)
        expect(result).not_to be_a_success
        expect(result.errors).to eq('Wrong step')
      end

      it 'returns error if this user does not belongs to this order' do
        order = create(:order)
        result = Orders::ChangeStatus.call(user: seller, order: order)
        expect(result).not_to be_a_success
        expect(result.errors).to eq('This user does not belongs to this order')
      end
    end

    context 'when driver made request' do
      let(:driver) { create(:driver) }

      context 'current status picking_up' do
        let(:order) { create(:order, :with_payment, :preorder, :picking_up, driver: driver) }

        it_behaves_like 'driver change status to', 'on_the_way'

        it 'returns error if this user does not belongs to this order' do
          order.update(driver: nil)
          result = Orders::ChangeStatus.call(user: driver, order: order)
          expect(result).not_to be_a_success
          expect(result.errors).to eq('This user does not belongs to this order')
        end
      end

      context 'current status ready' do
        let(:order) { create(:order, :preorder, :ready, driver: driver) }

        it_behaves_like 'driver change status to', 'picking_up'

        it 'returns error if this user does not belongs to this order' do
          order.update(driver: nil)
          result = Orders::ChangeStatus.call(user: driver, order: order)
          expect(result).not_to be_a_success
          expect(result.errors).to eq('This user does not belongs to this order')
        end
      end

      context 'current status on_the_way' do
        let(:order) { create(:order, :preorder, :on_the_way, driver: driver) }

        it_behaves_like 'driver change status to', 'delivered'

        it 'returns error if this user does not belongs to this order' do
          order.update(driver: nil)
          result = Orders::ChangeStatus.call(user: driver, order: order)
          expect(result).not_to be_a_success
          expect(result.errors).to eq('This user does not belongs to this order')
        end
      end

      context 'with current status looking_for_driver' do
        context 'for live/free order' do
          let(:order) { create(:order, :with_payment, :looking_for_driver) }

          it_behaves_like 'driver change status to', 'ready'

          it 'checks amount availability' do
            expect_any_instance_of(Orders::ChangeStatus).to receive(:amount_available?)
            Orders::ChangeStatus.call(user: driver, order: order)
          end
        end

        context 'for preorder order' do
          let(:order) { create(:order, :with_payment, :preorder, :looking_for_driver, cooking_time: '120') }

          it_behaves_like 'driver change status to', 'cooking'

          it 'sets estimation ready time' do
            result = Orders::ChangeStatus.call(user: driver, order: order)
            expect(result).to be_a_success
            expect(result.order.estimation_ready.strftime('%Y-%m-%dT%H:%M')).to eq((Time.now + 120.minutes).utc.strftime('%Y-%m-%dT%H:%M'))
          end

          it 'checks amount availability' do
            expect_any_instance_of(Orders::ChangeStatus).to receive(:amount_available?)
            Orders::ChangeStatus.call(user: driver, order: order)
          end
        end

        it 'assign this driver to the order' do
          order = create(:order, :with_payment, :looking_for_driver)
          result = Orders::ChangeStatus.call(user: driver, order: order)
          expect(result).to be_a_success
          expect(result.order.driver).to eq(driver)
        end
      end

      it 'returns error if request was made on wrong step' do
        order = create(:order, driver: driver)
        result = Orders::ChangeStatus.call(user: driver, order: order)
        expect(result).not_to be_a_success
        expect(result.errors).to eq('Wrong step')
      end

      it 'returns error if driver has current active order' do
        order = create(:order, :with_payment_authorized, :looking_for_driver)
        create(:order, :ready, :with_payment_authorized, driver: driver)
        result = Orders::ChangeStatus.call(user: driver, order: order)
        expect(result).not_to be_a_success
        expect(result.errors).to eq('Sorry, you already has active order')
      end
    end

    context 'when buyer made request' do
      let(:buyer) { create(:buyer) }

      context 'current status ready and self delivery' do
        let(:order) { create(:order, :ready, :self_delivery, buyer: buyer) }

        it_behaves_like 'buyer change status to', 'delivered'

        it 'returns error if request was made on wrong step' do
          order = create(:order, buyer: buyer)
          result = Orders::ChangeStatus.call(user: buyer, order: order)
          expect(result).not_to be_a_success
          expect(result.errors).to eq('Wrong step')
        end
      end
    end
  end
end
