require 'rails_helper'

RSpec.describe DriverFinderWorker, type: :worker do
  describe '#perform' do
    context 'for orders without drivers' do
      let(:order) { create(:order, driver: nil) }

      it 'should call driver finder' do
        expect(Drivers::Finder).to receive(:call).with(order: order, distance: 99, certified: false, except_distance: 11).once
        DriverFinderWorker.new.perform(order.id, distance: 99, except_distance: 11, certified: false)
      end
    end

    context 'for orders with driver' do
      let(:order) { create(:order) }

      it 'should return' do
        expect(Drivers::Finder).not_to receive(:call)
        DriverFinderWorker.new.perform(order.id, distance: 99, certified: false)
      end
    end
  end
end
