require 'rails_helper'

RSpec.describe OrderCanceletionWorker, type: :worker do
  describe '#perform' do

    before(:each) do
      stub_request(:post, 'https://sbpaymentservices.payfort.com/FortAPI/paymentApi').to_return(
          body: CANCEL_SUCCESS_RESPONSE.to_json
      )
    end

    context 'for reason' do
      context ':not_approved' do
        context 'with ready status' do
          let(:order) { create(:order, status: :ready) }

          it 'should return' do
            expect(Payments::CancelAuthorization).not_to receive(:call).with({order: order})
            expect_any_instance_of(Order).not_to receive(:cancel!)
            OrderCanceletionWorker.new.perform(order.id, :not_approved)
          end
        end

        context 'canceled order' do
          let(:order) { create(:order, status: 'canceled') }

          it 'should return' do
            expect_any_instance_of(Order).not_to receive(:cancel!)

            OrderCanceletionWorker.new.perform(order.id, :not_approved)
          end
        end


        context 'with pending status' do
          let(:order) { create(:order, :with_payment_authorized, status: :pending) }

          it 'should cancel order' do
            expect_any_instance_of(Order).to receive(:cancel!).once
            OrderCanceletionWorker.new.perform(order.id, :not_approved)
          end

          it 'should cancel payment' do
            expect(Payments::CancelAuthorization).to receive(:call).with({order: order}).once
            OrderCanceletionWorker.new.perform(order.id, :not_approved)
          end

          it 'creates cancellation record for the order' do
            expect(CancellationService).to receive(:call).with({
                                                                   order: order,
                                                                   who: 'system',
                                                                   reason: 'Not approved by seller'
                                                               }).once

            OrderCanceletionWorker.new.perform(order.id, :not_approved)
          end

          it 'should send notification' do
            expect(Push::Generator).to receive(:call).with({
                                                               users: [order.seller, order.buyer],
                                                               notification: :not_approved,
                                                               order: order
                                                           }).once
            OrderCanceletionWorker.new.perform(order.id, :not_approved)
          end
        end
      end

      context ':system' do
        context 'with driver' do
          let(:order) { create(:order) }

          it 'should return' do
            expect_any_instance_of(Order).not_to receive(:cancel!)
            OrderCanceletionWorker.new.perform(order.id, :system)
          end
        end

        context 'canceled order' do
          let(:order) { create(:order, status: 'canceled') }

          it 'should return' do
            expect_any_instance_of(Order).not_to receive(:cancel!)
            OrderCanceletionWorker.new.perform(order.id, :system)
          end
        end


        context 'without driver' do
          let(:order) { create(:order, driver: nil) }

          it 'should cancel order' do
            expect_any_instance_of(Order).to receive(:cancel!).once
            OrderCanceletionWorker.new.perform(order.id, :system)
          end

          it 'creates cancellation record for the order' do
            expect(CancellationService).to receive(:call).with({
                                                                   order: order,
                                                                   who: 'system',
                                                                   reason: 'Driver not found'
                                                               }).once

            OrderCanceletionWorker.new.perform(order.id, :system)
          end

          it 'should send notification' do
            expect(Push::Generator).to receive(:call).with({
                                                               users: [order.seller, order.buyer],
                                                               notification: :driver_not_found,
                                                               order: order
                                                           }).once
            OrderCanceletionWorker.new.perform(order.id, :system)
          end
        end
      end
    end
  end
end
