require 'rails_helper'

RSpec.describe CancellationService do
  describe '.call' do

    context 'driver cancel' do

      let(:driver) { create(:driver) }
      let(:order) { create(:order, :with_payment, driver: driver, status: 'ready') }

      it 'creates Cancellation record' do
        CancellationService.call(order: order,
                                 who: 'driver')

        expect(order.cancellations.count).to eq(1)
        expect(order.cancellations.first.who).to eq('driver')
        expect(order.cancellations.first.status).to eq('ready')
        expect(order.cancellations.first.user).to eq(driver)
        expect(order.cancellations.first.reason).to be_nil
      end

    end

    context 'seller cancel' do
      let(:seller) { create(:seller) }
      let(:order) { create(:order, :with_payment, seller: seller) }


      it 'creates Cancellation record' do
        CancellationService.call(order: order,
                                 who: 'seller')

        expect(order.cancellations.count).to eq(1)
        expect(order.cancellations.first.who).to eq('seller')
        expect(order.cancellations.first.status).to eq('pending')
        expect(order.cancellations.first.user).to eq(seller)
        expect(order.cancellations.first.reason).to be_nil
      end
    end


    context 'system cancel' do


      context 'drive was not found' do
        let(:order) { create(:order, :with_payment, status: 'looking_for_driver') }

        it 'creates Cancellation record' do

          CancellationService.call(order: order,
                                   who: 'system',
                                   reason: 'Driver not found')

          expect(order.cancellations.count).to eq(1)
          expect(order.cancellations.first.who).to eq('system')
          expect(order.cancellations.first.user).to eq(nil)
          expect(order.cancellations.first.reason).to eq('Driver not found')
        end
      end

      context 'Not approved by seller' do
        let(:order) { create(:order) }
        
        it 'creates Cancellation record' do
          CancellationService.call(order: order,
                                   who: 'system',
                                   reason: 'Not approved by seller')

          expect(order.cancellations.count).to eq(1)
          expect(order.cancellations.first.who).to eq('system')
          expect(order.cancellations.first.user).to eq(nil)
          expect(order.cancellations.first.reason).to eq('Not approved by seller')
        end
      end


    end


  end
end
